$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "missinglink/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "missinglink"
  s.version     = Missinglink::VERSION
  s.authors     = ["Trey Springer"]
  s.email       = ["trey@mustwin.com"]
  s.homepage    = "https://github.com/MustWin/missinglink"
  s.summary     = %q{Wrapper around the SurveyMonkey v2 API.}
  s.description = %q{This gem, when installed, enables pulling down surveys, questions, and responses from the SurveyMonkey API.}
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]

  s.add_dependency "rails", "~> 4.0"

  s.add_development_dependency "sqlite3", '~> 1.3'
  s.add_development_dependency "rspec-rails", '~> 2.14'
  s.add_development_dependency "webmock", '~> 1.17'
  s.add_development_dependency "vcr", "~> 2.8"
  s.add_runtime_dependency "typhoeus", '~> 0.6'
end
