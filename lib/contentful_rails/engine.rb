module ContentfulRails
  # Rails Engine that initializes the Contentful wrappers
  # This engine handles:
  #   * ContentfulModel configuration (settings and eager entry mapping loading)
  #   * Webhook Event handling (Entry publish/unpublish only)
  #   * Caching timestamp prepending on entry objects
  #   * Contentful MIME-type handling
  #   * Preview API caching behaviour and local authentication for accessing the Preview API
  class Engine < ::Rails::Engine
    isolate_namespace ContentfulRails

    config.generators do |g|
      g.test_framework :rspec
    end

    config.before_initialize do
      ContentfulRails.configure {} if ContentfulRails.configuration.nil?
    end

    initializer 'configure_contentful', before: :add_entry_mappings do
      ContentfulModel.configure do |config|
        config.access_token = ContentfulRails.configuration.access_token
        config.preview_access_token = ContentfulRails.configuration.preview_access_token
        config.management_token = ContentfulRails.configuration.management_token
        config.environment = ContentfulRails.configuration.environment
        config.default_locale = ContentfulRails.configuration.default_locale
        config.space = ContentfulRails.configuration.space
        config.options = ContentfulRails.configuration.contentful_options
      end
    end

    # Iterate through all models which inherit from ContentfulModel::Base
    # and add an entry mapping for them, so calls to the Contentful API return
    # the appropriate classes
    # If eager_load_entry_mapping is false, engine assumes entry mapping is set manually by
    # ContentfulRails.contentful_options[:entry_mapping] (passed through to Contentful.entry_mapping config)
    initializer 'add_entry_mappings', after: :configure_contentful do
      if defined?(ContentfulModel) && ContentfulRails.configuration.eager_load_entry_mapping
        Rails.application.eager_load!
        ContentfulModel::Base.descendents.each do |klass|
          klass.send(:add_entry_mapping)
        end
      end
    end

    initializer 'subscribe_to_webhook_events', after: :add_entry_mappings do
      ActiveSupport::Notifications.subscribe(/Contentful.*Entry\.publish/) do |_name, _start, _finish, _id, payload|
        content_type_id = payload[:sys][:contentType][:sys][:id]
        klass = ContentfulModel.configuration.entry_mapping[content_type_id]

        # klass will be nil if the content model has been created in contentful but the model in rails hasn't been added
        klass.send(:clear_cache_for, payload[:sys][:id]) unless klass.nil?
      end

      ActiveSupport::Notifications.subscribe(/Contentful.*Entry\.unpublish/) do |_name, _start, _finish, _id, payload|
        ActionController::Base.new.expire_fragment(%r{/.*#{payload[:sys][:id]}.*/})
      rescue NotImplementedError => e
        Rails.logger.error(e)
      end
    end

    initializer 'prepend_timestamps_module', after: :subscribe_to_webhook_events do
      if defined?(::ContentfulModel)
        ContentfulModel::Base.send(:prepend, ContentfulRails::Caching::Timestamps)
      end
    end

    # Module for defining Contentful vnd mime-type
    module ContentfulJSON
      # Contentful mime-type
      MIMETYPE = 'application/vnd.contentful.management.v1+json'.freeze
    end

    initializer 'add_contentful_mime_type' do
      Mime::Type.register(ContentfulJSON::MIMETYPE, :contentful_json)
      default_parsers = Rails::VERSION::MAJOR > 4 ? ActionDispatch::Http::Parameters::DEFAULT_PARSERS : ActionDispatch::ParamsParser::DEFAULT_PARSERS
      default_parsers[Mime::Type.lookup(ContentfulJSON::MIMETYPE)] = lambda do |body|
        JSON.parse(body)
      end
      ActionDispatch::Request.parameter_parsers = ActionDispatch::Request::DEFAULT_PARSERS if ActionDispatch::Request.respond_to?(:parameter_parsers=)
    end

    initializer 'add_preview_support' do
      ActiveSupport.on_load(:action_controller) do
        include ContentfulRails::Preview
      end
    end
  end
end
