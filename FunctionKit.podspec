Pod::Spec.new do |s|
  s.name             = "FunctionKit"
  s.version          = "0.1.0"
  s.summary          = "A framework for functional types and operations designed to fit naturally into Swift."

  s.description      = <<-DESC
                       A framework for functional types and operations designed to fit naturally into Swift. Includes operations such as composition and currying and types such as predicates and comparators.
                       DESC

  s.homepage         = "https://github.com/mpangburn/FunctionKit"
  s.license          = { :type => "MIT", :file => "LICENSE" }
  s.author           = { "mpangburn" => "michaelpangburn@comcast.net" }
  s.source           = { :git => "https://github.com/mpangburn/FunctionKit.git", :tag => s.version.to_s }

  s.ios.deployment_target = "11.0"

  s.source_files = "Sources/**/*"
end
