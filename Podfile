platform :ios, '15.5'

target 'FaceAISDK_iOS' do
  # pod update FaceAISDK_Core
  pod 'FaceAISDK_Core', :git => 'https://github.com/FaceAISDK/FaceAISDK_Core.git', :tag => '2026.07.16.beta2'
#  pod 'FaceAISDK_Core', '****version****'

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['BUILD_LIBRARY_FOR_DISTRIBUTION'] = 'NO'
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.5'
      if config.name == 'Debug'
        config.build_settings['SWIFT_COMPILATION_MODE'] = 'incremental'
        config.build_settings['SWIFT_OPTIMIZATION_LEVEL'] = '-Onone'
        config.build_settings['ONLY_ACTIVE_ARCH'] = 'YES'
      end
    end
  end

  installer.aggregate_targets.each do |target|
    support_dir = File.join(installer.sandbox.root, 'Target Support Files', target.label)
    Dir.glob(File.join(support_dir, '*.xcconfig')).each do |path|
      contents = File.read(path)
      contents = contents.gsub(/^BUILD_LIBRARY_FOR_DISTRIBUTION = .*\n/, "BUILD_LIBRARY_FOR_DISTRIBUTION = NO\n")
      contents = contents.gsub(' $(inherited) "${PODS_TARGET_SRCROOT}/Silent/framework"', '')
      File.write(path, contents)
    end
  end
end
