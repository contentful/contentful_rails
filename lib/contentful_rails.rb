require 'redcarpet'
require 'contentful_model'

require "contentful_rails/engine"
require "contentful_rails/development_constraint"
require 'contentful_rails/caching/timestamps'
require "contentful_rails/markdown_renderer"
require "contentful_rails/nested_resource"
require "contentful_rails/sluggable"
require "contentful_rails/preview"

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
                  :perform_caching,
                  :access_token,
                  :preview_access_token,
                  :space,
                  :contentful_options,
                  :preview_username,
                  :preview_password,
                  :preview_domain,
                  :enable_preview_domain

    def initialize
      @authenticate = true
      @slug_delimiter = "-"
      @perform_caching = Rails.configuration.action_controller.perform_caching
      @contentful_options = {}
    end
  end
end
