Pod::Spec.new do |s|
  s.name = 'KDTree'
  s.version = '0.0.1'
  s.platform = :ios
  s.ios.deployment_target = '7.0'
  s.prefix_header_file = 'KDTree/KDTree-Prefix.pch'
  s.source_files = 'KDTree/*.{h,m,c}'
  s.requires_arc = true
end
