Katalog::Application.routes.draw do
  get "index/title"

  resources :container_types

  devise_for :users

  resources :locations

  resources :topics
  resources :dossiers do
    collection do
      get :search, :overview, :report, :year_report
    end

    resources :containers
  end

  post "dossier_numbers/set_amount"
  
  resources :keywords do
    collection do
      get :search
    end
  end

  root :to => "dossiers#index"
end
