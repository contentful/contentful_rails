require 'spec_helper'

describe ContentfulRails::WebhooksController, type: :controller do
  routes { ContentfulRails::Engine.routes }

  describe "GET#debug" do
    it "just returns a 200" do
      get :debug
      expect(response).to have_http_status(200)
    end
  end
end
