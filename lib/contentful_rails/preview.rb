module ContentfulRails
  module Preview
    extend ActiveSupport::Concern

    included do
      before_action :check_preview_domain
      after_action :remove_preview_cache
      helper_method :preview?
    end
    # Check whether the subdomain being presented is the preview domain.
    # If so, set ContentfulModel to use the preview API, and request a username / password
    def check_preview_domain
      # If enable_preview_domain is not enabled, explicitly set use_preview_api false and return
      unless ContentfulRails.configuration.enable_preview_domain
        return
      end

      #check subdomain matches the configured one - we assume it's first sub.domain.in.the.array
      if request.subdomains.first == ContentfulRails.configuration.preview_domain
        authenticated = authenticate_with_http_basic  do |u,p|
          u == ContentfulRails.configuration.preview_username
          p == ContentfulRails.configuration.preview_password
        end
        # If user is authenticated, we're good to switch to the preview api
        if authenticated
          ContentfulModel.use_preview_api = true
        else
          #otherwise ask for user / pass
            request_http_basic_authentication
        end
      else
        #if the subdomain doesn't match the configured one, explicitly set to false
        ContentfulModel.use_preview_api = false
        return
      end

    end

    # If we're in preview mode, we need to remove the preview view caches which were created.
    # this is a bit of a hack but it's probably not feasible to turn off caching in preview mode.
    def remove_preview_cache
      # in preview mode, we alias_method_chain the cache_key method on ContentfulModel::Base to append 'preview/'
      # to the front of the key.
      return unless request.subdomain == ContentfulRails.configuration.preview_domain
      expire_fragment(%r{.*/preview/.*})
    end

    def preview?
      ContentfulModel.use_preview_api == true
    end
  end
end
