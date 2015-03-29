module ContentfulRails
  module Caching
    # A module to cache the whole of an object when it's returned from Contentful.
    # We override the find() method, because that's the only one which fetches a single record
    # from Contentful.
    module Objects
      def self.included(base)
        base.class_eval do
          alias_method_chain :find, :caching
        end
      end

      # A method called from an ActiveSupport::Notification subscriber. The published message
      # arrives from a webhook call.
      def self.clear_cache(params)

      end

      # the find() method from ContentfulModel but with a cache fetch first.
      def find_with_caching

      end


    end
  end
end