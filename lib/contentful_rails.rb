require "contentful_rails/engine"
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


    def initialize

    end
  end
end
