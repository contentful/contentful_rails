module ContentfulRails
  #A module to prepend into ContentfulModel::Base which will allow the model instance
  #to check the cache for its timestamp before making an expensive API call
  module CachedTimestamps
    def updated_at
      cache_key = "contentful_timestamp/#{self.class.content_type_id}/#{self.id}"
      Rails.cache.fetch(cache_key) do
        super
      end
    end
  end

end

