Pod::Spec.new do |s|
  s.name             = 'Networkfing'
  s.version          = '0.2.0'
  s.summary          = 'A short description of Networkfing.'
  s.description      = 'A longer description of Networkfing.'
  s.homepage         = 'https://github.com/li496939597/Networkfing'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Your Name' => '15182054435@163.com' }
  s.source           = { :git => 'https://github.com/li496939597/Networkfing.git', :tag => 'v0.2.0' }

  s.ios.deployment_target = '13.0'
  s.source_files     = 'Networkfing/Classes/**/*.{h,m,swift}'
  s.public_header_files = 'Networkfing/Classes/**/*.h'

  s.frameworks       = 'Foundation', 'Network', 'UIKit'
end
