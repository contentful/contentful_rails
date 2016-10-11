Rails.application.routes.draw do
  mount ContentfulRails::Engine => "/contentful"
end
