Katalog::Application.routes.draw do
  get "index/title"

  resources :container_types

  devise_for :users
#  scope "admin", :as => "admin" do
#    resource :users do
#      get 'index'
#    end
#  end
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
  end

  post "dossier_numbers/set_amount"
  
  resources :keywords do
    collection do
      get :search, :suggestions
    end
  end

  root :to => "dossiers#index"
end
