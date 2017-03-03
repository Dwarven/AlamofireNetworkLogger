Pod::Spec.new do |s|
  
  s.name                      = 'AlamofireNetworkLogger'
  s.version                   = '0.0.1'
  s.summary                   = 'Network Logger for Alamofire'
  s.homepage                  = 'https://github.com/Dwarven/AlamofireNetworkLogger'
  s.license                   = { :type => 'MIT', :file => 'LICENSE' }
  s.author                    = { 'Dwarven' => 'prison.yang@gmail.com' }
  s.social_media_url          = "https://twitter.com/DwarvenYang"
  s.source                    = { :git => 'https://github.com/Dwarven/AlamofireNetworkLogger.git', :tag => s.version }
  s.source_files              = 'Class/*.swift'
  s.ios.deployment_target     = '9.0'
  s.osx.deployment_target     = '10.11'
  s.tvos.deployment_target    = '9.0'
  s.watchos.deployment_target = '2.0'
  s.dependency                  'Alamofire'

end
