module ContentfulRails
  #A module to prepend into ContentfulModel::Base which will allow the model instance
  #to check the cache for its timestamp before making an expensive API call
  module CachedTimestamps
    def self.included(base)
      puts "Timestamps were included in #{base}"
      base.class_eval do
        alias_method_chain :updated_at, :caching
      end
    end
    def updated_at_with_caching
      cache_key = "contentful_timestamp/#{self.class.content_type_id}/#{self.id}"
      puts "#{cache_key}"
      Rails.cache.fetch(cache_key) do
        updated_at_without_caching
      end
    end
  end

end

