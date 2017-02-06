$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "contentful_rails/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "contentful_rails"
  s.version     = ContentfulRails::VERSION
  s.authors     = ["Error Creative Studio"]
  s.email       = ["hosting@errorstudio.co.uk"]
  s.homepage    = "https://github.com/errorstudio/contentful_rails"
  s.summary     = "A gem to help with hooking Contentful into your Rails application"
  s.description = "A gem to help with hooking Contentful into your Rails application"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "contentful_model", ">= 0.2.0"
  s.add_dependency "rails", ">= 4.1.8"
  s.add_dependency "redcarpet", "~> 3.2"
end
