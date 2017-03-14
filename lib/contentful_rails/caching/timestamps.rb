module ContentfulRails
  module Caching
    # A module to prepend into ContentfulModel::Base which will allow the model instance
    # to check the cache for its timestamp before making an expensive API call.
    # Also includes a module method to remove an existing timestamp.
    module Timestamps
      def self.prepended(base)
        base.extend ClassMethods
      end

      module ClassMethods
        # Clear an existing timestamp from the cache; called by the subscriber to the Entry notifications
        # from the WebhooksController.
        def clear_cache_for(item_id)
          cache_key = timestamp_cache_key(item_id)

          Rails.cache.delete(cache_key)
        end

        def timestamp_cache_key(item_id)
          "contentful_timestamp/#{self.content_type_id}/#{item_id}"
        end
      end

      def timestamp_cache_key
        self.class.timestamp_cache_key(id)
      end


      def updated_at
        if ContentfulRails.configuration.perform_caching && !ContentfulModel.use_preview_api
          Rails.cache.fetch(self.timestamp_cache_key) do
            super
          end
        else
          super
        end
      end

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

