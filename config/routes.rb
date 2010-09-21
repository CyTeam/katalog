Katalog::Application.routes.draw do
  get "index/keyword"

  get "index/title"

  resources :container_types

  devise_for :users

  resources :locations

  resources :dossiers, :topics, :topic_groups do
    collection do
      get :search
    end

    resources :containers
    
    resources :keywords do
      member do
        post :set_name
      end
    end
  end

  post "dossier_numbers/set_amount"
  
  root :to => "dossiers#index"
end
