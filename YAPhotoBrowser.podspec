Pod::Spec.new do |s|
  s.name          =  "YAPhotoBrowser"
  s.summary       =  "Photo Browser / Image progress and more"
  s.version       =  "0.6.1"
  s.homepage      =  "https://github.com/candyan/YAPhotoBrowser.git"
  s.license       =  { :type => 'MIT', :file => 'LICENSE' }
  s.author        =  { "Candyan" => "liuyanhp@gmail.com" }
  s.source        =  { :git => "https://github.com/candyan/YAPhotoBrowser.git", :tag => s.version.to_s }
  s.platform      =  :ios, '5.0'
  s.source_files  =  'Source/*.{h,m}'
  s.requires_arc  =  true
  s.dependency       'SDWebImage', '~> 3.5'
  s.dependency       'MRCircularProgressView', ':git => 'https://github.com/candyan/MRCircularProgressView.git', :tag => '0.2.0'
end
