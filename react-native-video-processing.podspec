require 'json'

package = JSON.parse(File.read(File.join(__dir__, 'package.json')))

Pod::Spec.new do |s|
  s.name             = package['name']
  s.version          = package['version']
  s.summary          = package['description']
  s.license          = package['license']
  s.homepage         = 'https://github.com/magicismight/react-native-svg'
  s.authors          = 'Shahen Hovhannisyan'
  s.source           = { :git => 'https://github.com/MassiveMediaMatch/react-native-video-processing.git', :tag => s.version }
  s.source_files     = 'ios/**/*.{h,m}'
  s.exclude_files    = 'ios/**/{examples,Mac}/**/*.{h,m}'
  s.requires_arc     = true
  s.platforms        = { :ios => "8.0"}
  s.frameworks       = 'CoreMedia', 'CoreVideo', 'OpenGLES', 'AVFoundation', 'QuartzCore', 'GPUImage', 'MobileCoreServices'
  s.dependency       'React'
end