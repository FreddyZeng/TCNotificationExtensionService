#
# Be sure to run `pod lib lint TCNotificationExtensionService.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'TCNotificationExtensionService'
  s.version          = '0.1.0'
  s.summary          = 'Notification Extension Service.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Notification Extension Service for 8891
                       DESC

  s.homepage         = 'http://code.addcn.com/10694/TCNotificationExtensionService'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'freddyzeng' => 'fanrong@addcn.com' }
  s.source           = { :git => 'http://code.addcn.com/10694/TCNotificationExtensionService.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '10.0'
  s.requires_arc = true
  s.static_framework = true
  s.weak_framework = 'UserNotifications'
  s.frameworks = 'UIKit', 'UserNotifications', 'AdSupport'

  s.source_files = 'TCNotificationExtensionService/Classes/**/*'

  s.pod_target_xcconfig = { 'SWIFT_INCLUDE_PATHS' => '$PROJECT_DIR/JPushExtension' }

  s.script_phase = { :name => 'CreateModulemap', :script => "touch \"${PROJECT_DIR}/JPushExtension/module.modulemap\"; \ncat <<EOF > \"${PROJECT_DIR}/JPushExtension/module.modulemap\"\nmodule JPushExtension [system] {\n\theader \"JPushNotificationExtensionService.h\"\n\texport *\n}\nEOF", :execution_position => :before_compile }


  # s.resource_bundles = {
  #   'TCNotificationExtensionService' => ['TCNotificationExtensionService/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'JPushExtension', '~> 1.1.2'
  s.dependency 'Alamofire', '~> 4.8.2'
end
