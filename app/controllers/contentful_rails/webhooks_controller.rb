class ContentfulRails::WebhooksController < ActionController::Base
  if ContentfulRails.configuration.authenticate_webhooks
    http_basic_authenticate_with  name: ContentfulRails.configuration.webhooks_username,
                                  password: ContentfulRails.configuration.webhooks_password
  end

  #this is where we receive a webhook, via a POST
  def create
    # The only things we need to handle in here (for now at least) are entries.
    # If there's been an update or a deletion, we just remove the cached timestamp.
    # The updated_at method which is included in ContentfulModel::Base in this gem
    # will check the cache first before making the call to the API.

    # We can then just use normal Rails russian doll caching without expensive API calls.

    update_type = headers('HTTP_X-Contentful-Topic')
    content_type_id = params['sys']['contentType']['id']
    item_id = params['sys']['id']
    cache_key = "contentful_timestamp/#{content_type_id}/#{item_id}"

    #handle publish by caching the new timestamp
    if update_type =~ %r(Entry)
      Rails.cache.delete(cache_key)
    end

    #must return an ok
    head :ok
  end

  def debug
    render text: "Debug method works ok"
  end



end