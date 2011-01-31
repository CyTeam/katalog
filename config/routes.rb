Katalog::Application.routes.draw do
  resources :container_types

  devise_for :users
  resources :users do
    member do
      post :unlock
    end
    collection do
      get :current
    end
  end
  
  resources :locations

  resources :topics
  resources :dossiers do
    collection do
      get :search, :overview, :report, :edit_report
    end

    resources :containers
    resources :dossier_numbers
  end

  post "dossier_numbers/set_amount"
  
  resources :keywords do
    collection do
      get :search, :suggestions
    end
  end

  root :to => "dossiers#index"
end
