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
        config.space = ContentfulRails.configuration.space
        config.options = ContentfulRails.configuration.contentful_options
      end
    end

    #Iterate through all models which inherit from ContentfulModel::Base
    #and add an entry mapping for them, so calls to the Contentful API return
    #the appropriate classes
    initializer "add_entry_mappings", after: :configure_contentful  do
      if defined?(ContentfulModel)
        Rails.application.eager_load!
        ContentfulModel::Base.descendents.each do |klass|
          klass.send(:add_entry_mapping)
        end
      end
    end

    initializer "add_contentful_mime_type" do
      Mime::Type.register "application/json", :json, ["application/vnd.contentful.management.v1+json"]
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
