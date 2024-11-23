Pod::Spec.new do |s|
  s.name             = 'Networkfing'
  s.version          = '0.2.0'
  s.summary          = 'A lightweight utility library for iOS development.'
  s.description      = <<-DESC
                       Networkfing is a lightweight utility library designed for iOS development. It offers features like network availability checks, random number generation, and string manipulation.
                       DESC
  s.homepage         = 'https://github.com/li496939597/Networkfing'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Li Zhang' => '15182054435@163.com' }
  s.source           = { :git => 'https://github.com/li496939597/Networkfing.git', :tag => 'v0.2.0' }

  s.ios.deployment_target = '12.0'
  s.source_files     = 'Networkfing/**/*.{h,m,swift}'
  s.public_header_files = 'Networkfing/**/*.h'

  s.frameworks       = 'Foundation', 'Network', 'UIKit'
end