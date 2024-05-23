Pod::Spec.new do |s|
  s.name             = 'SeamlessPayCore'
  s.version          = '2.0.0'
  s.summary          = 'There are three demo apps included with the framework.'

  s.description      = <<~DESC
    The SeamlessPay iOS SDK makes it quick and easy to build an excellent payment experience in your iOS app. We provide powerful elements that can be used out-of-the-box to collect your users’ payment details. We also expose the low-level APIs that power those UIs so that you can build fully custom experiences.
  DESC

  s.homepage         = 'https://github.com/seamlesspay/seamlesspay-ios'
  s.license          = { type: 'MIT', file: 'LICENSE' }
  s.author           = { 'Seamless Payments' => 'info@seamlesspay.com' }
  s.source           = { git: 'https://github.com/seamlesspay/seamlesspay-ios.git', tag: s.version.to_s }

  s.ios.deployment_target = '15.0'
  s.swift_versions = '5.7'

  s.source_files = [
    'SeamlessPayCore/Sources/**/*.{swift}',
    'SeamlessPayCoreObjC/include/**/*.{h,m}'
  ]
  s.exclude_files = 'SeamlessPayCore/Sources/SeamlessPayCore+ExportedImports.swift'

  s.resources = ['SeamlessPayCoreObjC/Resources/Assets']
  s.deprecated_in_favor_of = 'SeamlessPay'
end
