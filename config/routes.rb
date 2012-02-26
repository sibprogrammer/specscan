Specscan::Application.routes.draw do

  devise_for :users, :skip => [:sessions] do
    get 'login' => 'devise/sessions#new', :as => :new_user_session
    post 'login' => 'devise/sessions#create', :as => :user_session
    get 'logout' => 'devise/sessions#destroy', :as => :destroy_user_session
  end

  namespace :admin do
    resources :users do
      post 'lock', :on => :member
      post 'unlock', :on => :member
    end
    resources :vehicles do
      get 'map', :on => :member
      get 'reports', :on => :member
    end
    match "profile" => "users#profile"
  end

  root :to => 'admin/dashboard#index'

end
