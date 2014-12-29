class ContentfulRails::WebhooksController < ActionController::Base
  if ContentfulRails.configuration.authenticate_webhooks
    http_basic_authenticate_with  name: ContentfulRails.configuration.webhooks_username,
                                  password: ContentfulRails.configuration.webhooks_password
  end

  def create

  end

  def debug
    render text: "Debug method works ok"
  end

end