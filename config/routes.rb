ContentfulRails::Engine.routes.draw do
  #if ContentfulRails::Configuration.set_routes

    scope constraints: ContentfulRails::DevelopmentConstraint do
      get "/debug", to: "webhooks#debug"
    end

  #end
end
