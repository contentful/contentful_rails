ContentfulRails::Engine.routes.draw do
  #if ContentfulRails::Configuration.set_routes

  resources :webhooks, only: [:create] do
    collection do
      scope constraints: ContentfulRails::DevelopmentConstraint do
        get "/debug", to: "webhooks#debug"
      end
    end
  end

  #end
end
