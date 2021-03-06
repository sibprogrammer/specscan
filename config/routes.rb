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
      get 'impersonate', :on => :member
      get 'impersonation_logout', :on => :collection
      get 'update_balance', :on => :member
      post 'update_balance', :on => :member
    end
    resources :additional_users do
      post 'lock', :on => :member
      post 'unlock', :on => :member
    end
    resources :vehicles do
      get 'map', :on => :member
      get 'overview_map', :on => :collection
      get 'reports', :on => :member
      get 'day_report', :on => :member
      get 'get_movement_points', :on => :member
      get 'get_last_point', :on => :member
      get 'calibration', :on => :member
      put 'calibration_save', :on => :member
      get 'clear', :on => :member
      put 'clear_do', :on => :member
      get 'waybill', :on => :member
    end
    resources :sim_cards do
      post 'check_balance', :on => :member
    end
    resources :fuel_sensors
    resources :drivers
    resources :plans
    match "profile" => "users#profile"
    match "tools(/:action)", :controller => 'tools'
    match "search" => "search#results"
  end

  namespace :api do
    resources :vehicles, :only => :index do
      get 'location', :on => :member
    end
  end

  root :to => 'admin/dashboard#index'

end
