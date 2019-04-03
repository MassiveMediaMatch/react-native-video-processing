require 'json'

package = JSON.parse(File.read(File.join(__dir__, 'package.json')))

Pod::Spec.new do |s|
  s.name             = package['name']
  s.version          = package['version']
  s.summary          = package['description']
  s.license          = package['license']
  s.homepage         = 'https://github.com/magicismight/react-native-svg'
  s.authors          = 'Shahen Hovhannisyan'
  s.source           = { :git => 'https://github.com/MassiveMediaMatch/react-native-video-processing.git#c4a32b24a7b9d11c1845f187bc9f8bb858182f4e', :tag => s.version }
  s.source_files     = 'ios/**/*.{h,m}'
  s.requires_arc = true
  s.platforms        = { :ios => "8.0"}
  s.dependency         'React'
end