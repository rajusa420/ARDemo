platform :ios, '13.0'

target 'ARDemo' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for ARDemo
  pod 'Protobuf', :inhibit_warnings => true
  pod 'Firebase/Core', :inhibit_warnings => true
  pod 'GoogleMLKit/ObjectDetection'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
    end
  end
end
