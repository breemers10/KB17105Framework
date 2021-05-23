Pod::Spec.new do |spec|

  spec.name           = "KB17105Framework"
  spec.version        = "1.0.1"
  spec.summary        = "A short description of KB17105Framework."
  spec.homepage       = "https://github.com/breemers10/KB17105Framework"
  spec.license        = { :type => 'MIT', :file => 'LICENCE' }
  spec.author             = { "Kristaps Bremers" => "kristaps.bremers@chi.lv" }
  spec.source         = { :git => "https://github.com/breemers10/KB17105Framework.git", :tag => "1.0.1" }
  spec.source_files   = "GIFs/Classes", "GIFs/Classes/**/*.swift"
  spec.exclude_files  = "Classes/Exclude"
  spec.summary        = "KB17105Framework is framework for showing list of animated images."

  spec.swift_version  = '5.0'
  spec.ios.deployment_target = '11.0'

  spec.dependency 'RxSwift', '~> 5.1'
  spec.dependency 'RxCocoa', '~> 5.1'
  spec.dependency 'RxKeyboard', '~> 1.0'
  spec.dependency 'Kingfisher', '~> 5.13'
  spec.dependency 'ReachabilitySwift', '~> 5.0'

end
