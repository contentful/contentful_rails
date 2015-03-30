require "contentful_rails/engine"
require "contentful_rails/development_constraint"
require 'contentful_rails/caching/objects'
require 'contentful_rails/caching/timestamps'
require "contentful_rails/markdown_renderer"
require "contentful_rails/nested_resource"
require "contentful_rails/sluggable"
require 'redcarpet'

module ContentfulRails
  class << self
    attr_accessor :configuration
  end

  def self.configure
    self.configuration ||= Configuration.new
    yield(configuration)
  end

  class Configuration
    attr_accessor :authenticate_webhooks,
                  :webhooks_username,
                  :webhooks_password,
                  :slug_delimiter,
                  :caching_type,
                  :enable_caching

    def initialize
      @authenticate = true
      @slug_delimiter = "-"
      @caching_types = [:timestamp]
      @perform_caching = Rails.configuration.action_controller.perform_caching
    end
  end
end
