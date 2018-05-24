module ContentfulRails
  # A quick mixin to slugify a field other than 'slug'
  # NOTE that if you include sluggable (and define a slug field) in a class which responds to
  # slug() than you'll get a stack level too deep error.
  module Sluggable
    extend ActiveSupport::Concern

    class_methods do
      attr_accessor :slug_field
    end

    # Returns the slugified version of the :slug_field
    def slug
      send(self.class.slug_field).parameterize(ContentfulRails.configuration.slug_delimiter) if self.class.slug_field.present?
    end
  end
end
