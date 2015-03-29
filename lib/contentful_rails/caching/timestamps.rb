module ContentfulRails
  module Caching
    # A module to prepend into ContentfulModel::Base which will allow the model instance
    # to check the cache for its timestamp before making an expensive API call.
    # Also includes a module method to remove an existing timestamp.
    module Timestamps
      def self.included(base)
        base.class_eval do
          alias_method_chain :updated_at, :caching
        end
      end

      # Clear an existing timestamp from the cache; called by the subscriber to the Entry notifications
      # from the WebhooksController.
      def self.clear_cache(params)
        content_type_id = params[:sys][:contentType][:sys][:id]
        item_id = params[:sys][:id]
        cache_key = "contentful_timestamp/#{content_type_id}/#{item_id}"

        #delete the cache entry
        #if update_type =~ %r(Entry)
        Rails.cache.delete(cache_key)
      end

      # A replacement method for updated_at(), called when this module is included in ContentfulModel::Base
      def updated_at_with_caching
        if ContentfulRails.configuration.perform_caching
          Rails.cache.fetch(self.timestamp_cache_key) do
            updated_at_without_caching
          end
        else
          updated_at_without_caching
        end
      end

      def timestamp_cache_key
        "contentful_timestamp/#{self.class.content_type_id}/#{self.id}"
      end
    end
  end
end

