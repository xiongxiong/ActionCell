#
# Be sure to run `pod lib lint ActionCell.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'ActionCell'
  s.version          = '2.0.3'
  s.summary          = 'ActionCell, wrap UITableViewCell with actions.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
ActionCell, wraps UITableViewCell with actions elegantly, no need to inherit UITableViewCell, use swiping to trigger actions (known from the Mailbox App). I love it.
                       DESC

  s.homepage         = 'https://github.com/xiongxiong/ActionCell'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'xiongxiong' => 'xiongxiong0619@gmail.com' }
  s.source           = { :git => 'https://github.com/xiongxiong/ActionCell.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'Framework/ActionCell/**/*.{h,swift}'

  # s.resource_bundles = {
  #   'ActionCell' => ['ActionCell/Assets/*.png']
  # }

  s.public_header_files = 'Framework/ActionCell/*.h'
  s.frameworks = 'UIKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
