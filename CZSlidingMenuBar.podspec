#
# Be sure to run `pod lib lint CZSlidingMenuBar.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'CZSlidingMenuBar'
  s.version          = '1.1.3'
  s.summary          = 'A CZSlidingMenuBar.'

  s.description      = 'CZSlidingMenuBar can automatically interact with other scroll views on the slide.'

  s.homepage         = 'https://github.com/czeludzki/CZSlidingMenuBar'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'czeludzki' => 'czeludzki@gmail.com' }
  s.source           = { :git => 'https://github.com/czeludzki/CZSlidingMenuBar.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.0'

  s.source_files = 'CZSlidingMenuBar/Classes/**/*'

  # s.resource_bundles = {
  #   'CZSlidingMenuBar' => ['CZSlidingMenuBar/Assets/*.png']
  # }

  s.frameworks = 'UIKit'
  s.dependency 'Masonry'
end
