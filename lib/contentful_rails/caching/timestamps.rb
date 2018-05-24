module ContentfulRails
  # Module for caching extensions
  module Caching
    # A module to prepend into ContentfulModel::Base which will allow the model instance
    # to check the cache for its timestamp before making an expensive API call.
    # Also includes a module method to remove an existing timestamp.
    module Timestamps
      # @private
      def self.prepended(base)
        base.extend ClassMethods
      end

      # Class methods for Timestamps
      module ClassMethods
        # Clear an existing timestamp from the cache; called by the subscriber to the Entry notifications
        # from the WebhooksController.
        def clear_cache_for(item_id)
          cache_key = timestamp_cache_key(item_id)

          Rails.cache.delete(cache_key)
        end

        # Get the cache key for the timestamp
        def timestamp_cache_key(item_id)
          "contentful_timestamp/#{content_type_id}/#{item_id}"
        end
      end

      # Get the cache key for the timestamp for the current object
      def timestamp_cache_key
        self.class.timestamp_cache_key(id)
      end

      # Fetches updated_at from cache if set, otherwise calls contentful object
      def updated_at
        if ContentfulRails.configuration.perform_caching && !ContentfulModel.use_preview_api
          Rails.cache.fetch(imestamp_cache_key) do
            super
          end
        else
          super
        end
      end

      # Get the cache key
      def cache_key
        if ContentfulModel.use_preview_api
          "preview/#{super}"
        else
          super
        end
      end
    end
  end
end
