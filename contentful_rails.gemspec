$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "contentful_rails/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "contentful_rails"
  s.version     = ContentfulRails::VERSION
  s.authors     = ['Contentful GmbH (David Litvak Bruno)', 'Error Creative Studio']
  s.email       = ['david.litvak@contentful.com', 'hosting@errorstudio.co.uk']
  s.homepage    = "https://github.com/errorstudio/contentful_rails"
  s.summary     = "A gem to help with hooking Contentful into your Rails application"
  s.description = "A gem to help with hooking Contentful into your Rails application"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "rails", ">= 4.2"
  s.add_dependency "contentful_model", "~> 1.0"
  s.add_dependency "redcarpet", "~> 3.2"

  s.add_development_dependency 'vcr'
  s.add_development_dependency 'pry'
  s.add_development_dependency 'rspec', '~> 3'
  s.add_development_dependency 'rspec-rails', '~> 3'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'guard'
  s.add_development_dependency 'guard-rspec'
  s.add_development_dependency 'guard-rubocop'
  s.add_development_dependency 'guard-yard'
  s.add_development_dependency 'webmock', '~> 1', '>= 1.17.3'
  s.add_development_dependency 'tins', '~> 1.6.0'
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'rubocop', '~> 0.49.0'
  s.add_development_dependency 'pg'
  s.add_development_dependency 'dalli'
end
