Katalog::Application.routes.draw do

  resources :reports do
    collection do
      get :preview
    end
  end
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

  resources :topics do
    member do
      get :sub_topics
    end
  end
  
  resources :dossiers do
    collection do
      get :search, :overview, :report, :edit_report
    end

    resources :containers
    resources :dossier_numbers
    resources :versions
    resources :reservations
  end

  resources :dossier_numbers do
    collection do
      post :set_amount
    end
  end
  
  resources :keywords do
    collection do
      get :search, :suggestions
    end
  end

  resources :versions do
    member do
      post :revert
    end
  end

  resources :sphinx_admins do
    collection do
      get :exceptions, :word_forms
    end
  end

  resources :search_replaces

  resources :visitor_logs
  
  resources :reservations
  
  match "/user_session" => "application#update_session"

  root :to => "dossiers#index"
end
