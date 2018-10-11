Pod::Spec.new do |s|

#
	s.name = 'AOperation'
	
	s.version = '0.0.8'
	s.license = { :type => "MIT", :file => 'LICENSE' }
	s.summary = 'A Mediator Between Model (or Server) and View'

	s.homepage = 'https://github.com/ssamadgh/AOperation.git'
	s.author = { 'Seyed Samad Gholamzadeh' => 'ssamadgh@gmail.com' }
	s.source = { :git => 'https://github.com/ssamadgh/AOperation.git', :tag => s.version }
 	# s.documentation_url = 'https://ssamadgh.github.io/AOperation/'
	
	s.platform = :ios
	s.ios.deployment_target = '10.0'
 	#s.osx.deployment_target = '10.10'
 	#s.tvos.deployment_target = '9.0'
  	#s.watchos.deployment_target = '2.0'

	
	s.source_files = 'Source/Shared/**/*.swift'
	s.ios.source_files = 'Source/iOS/**/*.swift'

	s.swift_version = '4.2'
end

