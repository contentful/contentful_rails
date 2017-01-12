module ContentfulRails
  class Engine < ::Rails::Engine

    isolate_namespace ContentfulRails

    config.before_initialize do
      if ContentfulRails.configuration.nil?
        ContentfulRails.configure {}
      end
    end

    initializer "configure_contentful", before: :add_entry_mappings do
      ContentfulModel.configure do |config|
        config.access_token = ContentfulRails.configuration.access_token
        config.preview_access_token = ContentfulRails.configuration.preview_access_token
        config.management_token = ContentfulRails.configuration.management_token
        config.default_locale = ContentfulRails.configuration.default_locale
        config.space = ContentfulRails.configuration.space
        config.options = ContentfulRails.configuration.contentful_options
      end
    end

    #Iterate through all models which inherit from ContentfulModel::Base
    #and add an entry mapping for them, so calls to the Contentful API return
    #the appropriate classes
    #If eager_load_entry_mapping is false, engine assumes entry mapping is set manually by
    #ContentfulRails.contentful_options[:entry_mapping] (passed through to Contentful.entry_mapping config)
    initializer "add_entry_mappings", after: :configure_contentful  do
      if defined?(ContentfulModel) && ContentfulRails.configuration.eager_load_entry_mapping
        Rails.application.eager_load!
        ContentfulModel::Base.descendents.each do |klass|
          klass.send(:add_entry_mapping)
        end
      end
    end

    initializer "subscribe_to_webhook_events", after: :add_entry_mappings do
      ActiveSupport::Notifications.subscribe(/Contentful.*Entry\.publish/) do |name, start, finish, id, payload|
        content_type_id = payload[:sys][:contentType][:sys][:id]
        klass = ContentfulModel.configuration.entry_mapping[content_type_id]
        # klass will be nil if the content model has been created in contentful but the model in rails hasn't been added
        unless klass.nil?
          klass.send(:clear_cache_for, payload[:sys][:id])
        end

      end

      ActiveSupport::Notifications.subscribe(/Contentful.*Entry\.unpublish/) do |name, start, finish, id, payload|
        ActionController::Base.new.expire_fragment(%r{.*#{payload[:sys][:id]}.*})
      end
    end

    initializer "add_contentful_mime_type" do
      content_type = "application/vnd.contentful.management.v1+json"
      Mime::Type.register "application/json", :contentful_json, [content_type]

      ActionDispatch::ParamsParser::DEFAULT_PARSERS[Mime::Type.lookup(content_type)] = lambda do |body|
        JSON.parse(body)
      end
    end

    initializer "add_preview_support" do
      ActiveSupport.on_load(:action_controller) do
        include ContentfulRails::Preview
      end
    end

    config.to_prepare do
      if defined?(::ContentfulModel)
        ContentfulModel::Base.send(:include, ContentfulRails::Caching::Timestamps)
      end
    end

  end
end
