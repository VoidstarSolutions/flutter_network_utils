#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'flutter_network_utils'
  s.version          = '1.0.0'
  s.summary          = 'Small Plugin for querying basic network info on iOS and Android'
  s.description      = <<-DESC
Small network info query plugin.
                       DESC
  s.homepage         = 'http://www.voidstarsolutions.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Voidstar Solutions' => 'zach@voidstarsolutions.com' }
  s.source           = { :local => '/' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'

  s.ios.deployment_target = '10.0'
end

