$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "xyz/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "xyz"
  s.version     = Xyz::VERSION
  s.authors     = [""]
  s.email       = ["dukeoflaser@gmail.com"]
  s.homepage    = "TODO"
  s.summary     = "TODO: Summary of Xyz."
  s.description = "TODO: Description of Xyz."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "rails", "~> 5.0.2"

  s.add_development_dependency "sqlite3"
end
