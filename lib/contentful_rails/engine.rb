module ContentfulRails
  class Engine < ::Rails::Engine
    initializer "add_entry_mappings_for_contentful_models" do
      if defined?(ContentfulModel)
        Rails.application.eager_load!
        ContentfulModel::Base.descendents.each do |klass|
          klass.send(:add_entry_mapping)
        end
      end
    end
  end
end
