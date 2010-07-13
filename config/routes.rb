Katalog::Application.routes.draw do |map|
  get "index/keyword"

  get "index/title"

  resources :container_types

  devise_for :users

  resources :locations

  resources :dossiers, :topics, :topic_groups do
    collection do
      get :search
    end
  end

  root :to => "dossiers#index"
end
