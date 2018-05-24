ContentfulRails::Engine.routes.draw do
  resources :webhooks, only: [:create], defaults: { format: :json } do
    collection do
      scope constraints: ContentfulRails::DevelopmentConstraint do
        get '/debug', to: 'webhooks#debug'
      end
    end
  end
end
