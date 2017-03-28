Pod::Spec.new do |s|

  s.name          = "RolloutManager"
  s.version       = "0.2.4"
  s.summary       = "AutoCAD 360 component that rollout features gradualy"
  s.homepage      = "http://www.autodesk.com"
  s.license       = { :type => "MIT", :file => "LICENCE.md" }
  s.author        = { "Asaf Shveki" => "asaf.shveki@autodesk.com" }
  s.source        = { :git => "???", :tag => '0.2.4' }
  s.platform      = :ios, '8.0'
  s.source_files  = 'RolloutManager/**/*.{h,m}'
  s.frameworks    = 'Foundation'
  s.requires_arc  = true

end
