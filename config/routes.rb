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
      get 'day_report', :on => :member
      get 'get_movement_points', :on => :member
    end
    match "profile" => "users#profile"
    resources :sim_cards do
      post 'check_balance', :on => :member
    end
    resources :fuel_sensors
  end

  root :to => 'admin/dashboard#index'

end
