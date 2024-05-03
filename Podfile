# Uncomment the next line to define a global platform for your project
# platform :ios, '17.0'

target 'NEWSApp' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
 pod 'SDWebImage' , '~>3.8'  
  pod 'Cosmos', '~> 25.0'
pod 'ReachabilitySwift'

  # Pods for NEWSApp
post_install do |installer|
    installer.generated_projects.each do |project|
        project.targets.each do |target|
            target.build_configurations.each do |config|
                config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
            end
        end
    end
end  
target 'NEWSAppTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'NEWSAppUITests' do
    # Pods for testing
  end

end
