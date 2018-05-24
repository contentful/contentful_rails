require 'simplecov'
SimpleCov.start

require 'rails/all'
require 'contentful_rails'
require 'vcr'
require 'rspec'
require 'rspec/rails'

ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../dummy/config/environment', __FILE__)

abort("The Rails environment is running in production mode!") if Rails.env.production?

ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  config.filter_run :focus => true
  config.run_all_when_everything_filtered = true

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
  config.shared_context_metadata_behavior = :apply_to_host_groups

  config.fixture_path = "#{::Rails.root}/spec/fixtures"
  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!
end

VCR.configure do |c|
  c.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  c.ignore_localhost = true
  c.hook_into :webmock
  c.default_cassette_options = { record: :once }
end

def vcr(name, &block)
  VCR.use_cassette(name, &block)
end
