#
# Be sure to run `pod lib lint XJHTextInputIntercepterKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'XJHTextInputIntercepterKit'
  s.version          = '0.1.7'
  s.summary          = 'XJHTextInputIntercepterKit is a input intercepter that you can custom it.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = 'XJHTextInputIntercepterKit is a input intercepter that you can custom it.@XJHTextInputIntercepterKit'

  s.homepage         = 'https://github.com/cocoadogs/XJHTextInputIntercepterKit'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'cocoadogs' => 'cocoadogs@163.com' }
  s.source           = { :git => 'https://github.com/cocoadogs/XJHTextInputIntercepterKit.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '10.0'

  s.public_header_files = 'XJHTextInputIntercepterKit/XJHTextInputIntercepterKit.h'
  s.source_files = 'XJHTextInputIntercepterKit/XJHTextInputIntercepterKit.h'
  
  s.subspec 'Intercepter' do |ss|
    ss.public_header_files = 'XJHTextInputIntercepterKit/XJHTextInputIntercepter.h'
    ss.source_files = 'XJHTextInputIntercepterKit/XJHTextInputIntercepter.{h,m}','XJHTextInputIntercepterKit/XJHTextInputIntercepterInternalImp.{h,m}'
    ss.dependency 'XJHTextInputIntercepterKit/Dispatcher'
  end
  
  s.subspec 'Dispatcher' do |ss|
    ss.public_header_files = 'XJHTextInputIntercepterKit/XJHTextInputIntercepterDispatcher.h'
    ss.source_files = 'XJHTextInputIntercepterKit/XJHTextInputIntercepterDispatcher.{h,m}'
    ss.dependency 'XJHMultiProxyKit'
  end
  
  # s.resource_bundles = {
  #   'XJHTextInputIntercepterKit' => ['XJHTextInputIntercepterKit/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
