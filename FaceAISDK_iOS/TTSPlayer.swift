import Foundation
import AVFoundation
import os.log
#if canImport(UIKit)
import UIKit
#endif

// MARK: - TTSPlayer

/// iOS 原生语音播报管理器（兼容 iOS 15 ~ 26）
final class TTSPlayer: NSObject {

    static let shared = TTSPlayer()

    // MARK: - 播报策略

    enum Policy {
        case interrupt
        case enqueue
        case dropIfBusy
    }

    // MARK: - 状态

    enum State: Equatable {
        case idle
        case speaking(String)
        case paused
    }

    var onStateChanged: ((State) -> Void)?

    /// State 仅限在主线程读写，确保外部 UI 绑定的绝对安全
    private(set) var state: State = .idle {
        didSet {
            guard state != oldValue else { return }
            onStateChanged?(state)
        }
    }

    var isSpeaking: Bool {
        if case .speaking = state { return true }
        return false
    }

    // MARK: - Private

    private let synthesizer = AVSpeechSynthesizer()
    private let log: OSLog
    
    // 💡 核心优化：创建一个专用的默认优先级后台串行队列，隔离所有耗时/阻塞 API
    private let workQueue = DispatchQueue(label: "com.faceAI.sdk.ttsPlayer", qos: .default)

    // 以下变量现在仅在 workQueue 中访问，天然线程安全
    private var isSessionActive = false
    private var pendingDeactivation: DispatchWorkItem?
    private let sessionDeactivationDelay: TimeInterval = 1.5

    private var voiceCache: [String: AVSpeechSynthesisVoice] = [:]

    private var lastSpokenText: String?
    private var lastSpokenTime: CFAbsoluteTime = 0
    private let dedupInterval: TimeInterval = 0.5

    private var interruptedBySystem = false

    // MARK: - Init

    private override init() {
        self.log = OSLog(subsystem: "com.faceAI.sdk", category: "TTSPlayer")
        super.init()
        synthesizer.delegate = self
        addObservers()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Public API

    /// 播报文本
    func speak(_ text: String?,
               language: String? = nil,
               rate: Float = 0.5,
               pitch: Float = 0.98,
               policy: Policy = .dropIfBusy) {
        guard let text = text, !text.isEmpty else { return }

        // 💡 核心优化：将所有操作派发到后台队列，避免阻塞主线程
        workQueue.async { [weak self] in
            guard let self = self else { return }

            let now = CFAbsoluteTimeGetCurrent()
            if text == self.lastSpokenText && (now - self.lastSpokenTime) < self.dedupInterval {
                return
            }

            switch policy {
            case .interrupt:
                self.synthesizer.stopSpeaking(at: .immediate)
            case .enqueue:
                break
            case .dropIfBusy:
                // 现在在后台队列查询 isSpeaking，不会引起优先级反转
                if self.synthesizer.isSpeaking {
                    return
                }
            }

            self.activateSessionIfNeeded()

            let utterance = AVSpeechUtterance(string: text)
            let clampedRate = min(max(rate, 0), 1)
            utterance.rate = AVSpeechUtteranceMinimumSpeechRate
                + clampedRate * (AVSpeechUtteranceMaximumSpeechRate - AVSpeechUtteranceMinimumSpeechRate)
            
            utterance.pitchMultiplier = min(max(pitch, 0.5), 2.0)
            utterance.preUtteranceDelay = 0.05
            utterance.postUtteranceDelay = 0.15
            
            // speechVoices 查询也被移到了后台执行
            utterance.voice = self.cachedVoice(for: language)

            self.lastSpokenText = text
            self.lastSpokenTime = now

            self.synthesizer.speak(utterance)
        }
    }

    func pause() {
        workQueue.async { [weak self] in
            guard let self = self else { return }
            if self.synthesizer.isSpeaking {
                self.synthesizer.pauseSpeaking(at: .word)
            }
        }
    }

    func resume() {
        workQueue.async { [weak self] in
            guard let self = self else { return }
            if self.synthesizer.isPaused {
                self.activateSessionIfNeeded()
                self.synthesizer.continueSpeaking()
            }
        }
    }

    func stop() {
        workQueue.async { [weak self] in
            guard let self = self else { return }
            self.stopSynthesizerIfActive()
        }
    }

    func release() {
        workQueue.async { [weak self] in
            guard let self = self else { return }
            self.stopSynthesizerIfActive()
            self.deactivateSessionNow()
            self.voiceCache.removeAll()
        }
    }
    
    private func stopSynthesizerIfActive() {
        if synthesizer.isSpeaking || synthesizer.isPaused {
            synthesizer.stopSpeaking(at: .immediate)
        }
    }

    // MARK: - Audio Session (仅在 workQueue 内调用)

    private func activateSessionIfNeeded() {
        pendingDeactivation?.cancel()
        pendingDeactivation = nil

        guard !isSessionActive else { return }
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .spokenAudio, options: [.duckOthers])
            try session.setActive(true, options: .notifyOthersOnDeactivation)
            isSessionActive = true
        } catch {
            os_log("AudioSession activate failed: %{public}@", log: log, type: .error, error.localizedDescription)
        }
    }

    private func scheduleDeactivation() {
        pendingDeactivation?.cancel()
        let item = DispatchWorkItem { [weak self] in
            self?.deactivateSessionNow()
        }
        pendingDeactivation = item
        // 在后台队列调度延时任务
        workQueue.asyncAfter(deadline: .now() + sessionDeactivationDelay, execute: item)
    }

    private func deactivateSessionNow() {
        pendingDeactivation?.cancel()
        pendingDeactivation = nil
        guard isSessionActive else { return }
        do {
            try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
            isSessionActive = false
        } catch {
            os_log("AudioSession deactivate failed: %{public}@", log: log, type: .error, error.localizedDescription)
        }
    }

    // MARK: - Observers

    private func addObservers() {
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(handleInterruption),
                       name: AVAudioSession.interruptionNotification, object: nil)
        nc.addObserver(self, selector: #selector(handleRouteChange),
                       name: AVAudioSession.routeChangeNotification, object: nil)
        #if canImport(UIKit)
        nc.addObserver(self, selector: #selector(handleDidEnterBackground),
                       name: UIApplication.didEnterBackgroundNotification, object: nil)
        #endif
    }

    @objc private func handleInterruption(_ notification: Notification) {
        guard let info = notification.userInfo,
              let typeValue = info[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else { return }

        let optionsValue = info[AVAudioSessionInterruptionOptionKey] as? UInt ?? 0
        let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)

        // 统一派发到工作队列处理
        workQueue.async { [weak self] in
            guard let self = self else { return }
            
            switch type {
            case .began:
                self.interruptedBySystem = self.synthesizer.isSpeaking || self.synthesizer.isPaused
                self.isSessionActive = false

            case .ended:
                let shouldResume = self.interruptedBySystem
                self.interruptedBySystem = false

                if shouldResume, options.contains(.shouldResume) {
                    self.activateSessionIfNeeded()
                    self.synthesizer.continueSpeaking()
                } else if shouldResume {
                    self.stopSynthesizerIfActive()
                }

            @unknown default:
                break
            }
        }
    }

    @objc private func handleRouteChange(_ notification: Notification) {
        guard let info = notification.userInfo,
              let reasonValue = info[AVAudioSessionRouteChangeReasonKey] as? UInt,
              let reason = AVAudioSession.RouteChangeReason(rawValue: reasonValue) else { return }

        if reason == .oldDeviceUnavailable {
            workQueue.async { [weak self] in
                if self?.synthesizer.isSpeaking == true {
                    self?.synthesizer.pauseSpeaking(at: .word)
                }
            }
        }
    }

    @objc private func handleDidEnterBackground() {
        workQueue.async { [weak self] in
            self?.stopSynthesizerIfActive()
        }
    }

    // MARK: - Voice Selection (仅在 workQueue 内调用)

    private func cachedVoice(for language: String?) -> AVSpeechSynthesisVoice? {
        let lang = language ?? Locale.preferredLanguages.first ?? "en-US"
        if let cached = voiceCache[lang] { return cached }
        let voice = bestVoice(for: lang)
        if let voice = voice { voiceCache[lang] = voice }
        return voice
    }

    private func bestVoice(for lang: String) -> AVSpeechSynthesisVoice? {
        let voices = AVSpeechSynthesisVoice.speechVoices()

        let candidates: [AVSpeechSynthesisVoice] = {
            let exact = voices.filter { $0.language == lang }
            if !exact.isEmpty { return exact }

            let prefix = lang.components(separatedBy: "-").first ?? lang
            let prefixed = voices.filter { $0.language.hasPrefix(prefix) }
            if !prefixed.isEmpty { return prefixed }

            if prefix == "zh" {
                let cn = voices.filter { $0.language == "zh-CN" }
                if !cn.isEmpty { return cn }
                let tw = voices.filter { $0.language == "zh-TW" }
                if !tw.isEmpty { return tw }
            }

            return voices.filter { $0.language == "en-US" }
        }()

        return candidates.max(by: { $0.quality.rawValue < $1.quality.rawValue })
    }

    // MARK: - Helpers

    /// 安全地向主线程抛出状态变更
    private func updateStateOnMainThread(_ newState: State) {
        if Thread.isMainThread {
            self.state = newState
        } else {
            DispatchQueue.main.async { [weak self] in
                self?.state = newState
            }
        }
    }
}

// MARK: - AVSpeechSynthesizerDelegate

extension TTSPlayer: AVSpeechSynthesizerDelegate {

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        updateStateOnMainThread(.speaking(utterance.speechString))
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        updateStateOnMainThread(.idle)
        workQueue.async { [weak self] in
            self?.scheduleDeactivation()
        }
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        updateStateOnMainThread(.idle)
        workQueue.async { [weak self] in
            self?.scheduleDeactivation()
        }
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didPause utterance: AVSpeechUtterance) {
        updateStateOnMainThread(.paused)
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didContinue utterance: AVSpeechUtterance) {
        updateStateOnMainThread(.speaking(utterance.speechString))
    }
}
