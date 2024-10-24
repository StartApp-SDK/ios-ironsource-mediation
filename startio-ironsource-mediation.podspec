Pod::Spec.new do |spec|

  spec.name         = "startio-ironsource-mediation"
  spec.version      = "1.1.3"
  spec.summary      = "Start.io <-> ironSource iOS Mediation Adapter."

  spec.description  = <<-DESC
  Using this adapter you will be able to integrate Start.io SDK via ironSource mediation
                   DESC

  spec.homepage     = "https://www.start.io"
  spec.license      = { :type => "Apache License, Version 2.0", :file => "LICENSE" }
  spec.author       = { "iOS Dev" => "iosdev@startapp.com" }
  
  spec.platform     = :ios, "12.0"
  spec.source       = { :git => "https://github.com/StartApp-SDK/ios-ironsource-mediation.git", :tag => spec.version.to_s }
  spec.source_files = "StartioIronSourceMediation/*.*"
  spec.frameworks   = "Foundation", "UIKit"

  spec.requires_arc = true
  spec.static_framework = true
  
  spec.dependency "IronSourceSDK", "~> 8.4"
  spec.dependency "StartAppSDK", "~> 4.10"

end
