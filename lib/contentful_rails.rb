require "contentful_rails/engine"
require "contentful_rails/development_constraint"
require "contentful_rails/cached_timestamps"
require "contentful_rails/markdown_renderer"
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
    attr_accessor :authenticate_webhooks, :webhooks_username, :webhooks_password

    def initialize
      @authenticate = true
    end
  end
end
