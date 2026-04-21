#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint keyboard_size_peek.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'keyboard_size_peek'
  s.version          = '0.1.1'
  s.summary          = "Reports the keyboard's final height before the show/hide animation starts."
  s.description      = <<-DESC
Reports the keyboard's final height before the show/hide animation starts. Size bottom sheets and attachment panels without debounce magic.
                       DESC
  s.homepage         = 'https://github.com/stojanovventures/keyboard_size_peek'
  s.license          = { :type => 'MIT', :file => '../LICENSE' }
  s.author           = { 'Viktor Stojanov' => 'hello@stojanovventures.com' }
  s.source           = { :git => 'https://github.com/stojanovventures/keyboard_size_peek.git', :tag => s.version.to_s }
  s.source_files = 'keyboard_size_peek/Sources/keyboard_size_peek/**/*.swift'
  s.resource_bundles = {'keyboard_size_peek_privacy' => ['keyboard_size_peek/Sources/keyboard_size_peek/Resources/PrivacyInfo.xcprivacy']}
  s.dependency 'Flutter'
  s.platform = :ios, '13.0'

  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
