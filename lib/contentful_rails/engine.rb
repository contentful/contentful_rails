module ContentfulRails
  class Engine < ::Rails::Engine

    isolate_namespace ContentfulRails

    #Iterate through all models which inherit from ContentfulModel::Base
    #and add an entry mapping for them, so calls to the Contentful API return
    #the appropriate classes.
    initializer "add_entry_mappings_for_contentful_models" do
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

    #if we're at the end of initialization and there's no config object,
    #set one up with the default options (i.e. an empty proc)
    config.after_initialize do
      if ContentfulRails.configuration.nil?
        ContentfulRails.configure {}
      end
    end

    config.to_prepare do
      if defined?(::ContentfulModel)
        types = [ContentfulRails.configuration.caching_types] unless ContentfulRails.configuration.caching_types.is_a?(Array)
        case ContentfulRails.configuration.caching_type
          when :timestamp
            ContentfulModel::Base.send(:include, ContentfulRails::Caching::Timestamps)
          when :object
            ContentfulModel::Base.send(:include, ContentfulRails::Caching::Objects)
        end
      end
    end

  end
end
