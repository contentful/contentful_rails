module ContentfulRails
  module Caching
    # A module to prepend into ContentfulModel::Base which will allow the model instance
    # to check the cache for its timestamp before making an expensive API call.
    # Also includes a module method to remove an existing timestamp.
    module Timestamps
      def self.included(base)
        base.extend ClassMethods
        base.class_eval do
          alias_method_chain :updated_at, :caching
          alias_method_chain :cache_key, :preview
        end
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


      # A replacement method for updated_at(), called when this module is included in ContentfulModel::Base
      def updated_at_with_caching
        if ContentfulRails.configuration.perform_caching && !ContentfulModel.use_preview_api
          Rails.cache.fetch(self.timestamp_cache_key) do
            updated_at_without_caching
          end
        else
          updated_at_without_caching
        end
      end

      def timestamp_cache_key
        self.class.timestamp_cache_key(id)
      end

      def cache_key_with_preview
        if ContentfulModel.use_preview_api
          "preview/#{cache_key_without_preview}"
        else
          cache_key_without_preview
        end
      end


    end
  end
end

