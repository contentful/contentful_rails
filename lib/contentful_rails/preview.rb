module ContentfulRails
  module Preview
    extend ActiveSupport::Concern

    included do
      before_action :check_preview_domain
    end
    # Check whether the subdomain being presented is the preview domain.
    # If so, set ContentfulModel to use the preview API, and request a username / password
    def check_preview_domain
      return unless ContentfulRails.configuration.enable_preview_domain
      if request.subdomain == ContentfulRails.configuration.preview_domain
        authenticated = authenticate_with_http_basic  do |u,p|
          u == ContentfulRails.configuration.preview_username
          p == ContentfulRails.configuration.preview_password
        end
        if authenticated
          ContentfulModel.use_preview_api = true
        else
          request_http_basic_authentication
        end
      end
    end
  end
end