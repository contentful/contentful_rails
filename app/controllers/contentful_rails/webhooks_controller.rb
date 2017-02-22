class ContentfulRails::WebhooksController < ActionController::Base
  protect_from_forgery with: :exception

  if ContentfulRails.configuration.authenticate_webhooks
    http_basic_authenticate_with  name: ContentfulRails.configuration.webhooks_username,
                                  password: ContentfulRails.configuration.webhooks_password
  end

  # protect_from_forgery with: :exception
  # skip_before_filter :verify_authenticity_token, :only => [:create]

  #this is where we receive a webhook, via a POST
  def create
    # The only things we need to handle in here (for now at least) are entries.
    # If there's been an update or a deletion, we just remove the cached timestamp.
    # The updated_at method which is included in ContentfulModel::Base in this gem
    # will check the cache first before making the call to the API.

    # We can then just use normal Rails russian doll caching without expensive API calls.
    request.format = :json
    update_type = request.headers['HTTP_X_CONTENTFUL_TOPIC']

    # All we do here is publish an ActiveSupport::Notification, which is subscribed to
    # elsewhere. In this gem are subscription options for timestamp or object caching,
    # implement your own and subscribe in an initializer.
    ActiveSupport::Notifications.instrument("Contentful.#{update_type}", params)

    #must return an ok
    render nothing: true
  end

  def debug
    render text: "Debug method works ok"
  end

  private

  def webhook_params
    params.permit!
    params.require(:sys).permit(:id, contentType: [sys: [:id]])
  end



end
