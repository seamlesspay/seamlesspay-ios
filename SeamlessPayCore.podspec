#
# Be sure to run `pod lib lint SeamlessPayCore.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'SeamlessPayCore'
  s.version          = '1.0.2'
  s.summary          = 'There are three demo apps included with the framework.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: The SeamlessPay iOS SDK makes it quick and easy to build an excellent payment experience in your iOS app. We provide powerful elements that can be used out-of-the-box to collect your users’ payment details. We also expose the low-level APIs that power those UIs so that you can build fully custom experiences.
                       DESC

  s.homepage         = 'https://github.com/seamlesspay/seamlesspay-ios'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Seamless Payments' => 'info@seamlesspay.com' }
  s.source           = { :git => 'https://github.com/seamlesspay/seamlesspay-ios.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '11.0'

  s.source_files = 'SeamlessPayCore/Classes/*'
  s.resources = 'SeamlessPayCore/Assets/*'
  
  # s.resource_bundles = {
  #   'SeamlessPayCore' => ['SeamlessPayCore/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
