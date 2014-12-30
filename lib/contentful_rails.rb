require "contentful_rails/engine"
require "contentful_rails/development_constraint"
require "contentful_rails/cached_timestamps"
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
    attr_accessor :set_routes, :authenticate_webhooks, :webhooks_username, :webhooks_password

    def initialize
      @set_routes = true
      @authenticate = true
    end
  end
end
