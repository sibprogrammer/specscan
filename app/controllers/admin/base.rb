class Admin::Base < ApplicationController

  layout 'admin'
  before_filter :authenticate_user!, :set_menu, :set_search, :set_sidebar_actions

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, :alert => t('admin.dashboard.index.access_denied')
  end

  rescue_from ActiveRecord::RecordNotFound do |exception|
    redirect_to root_url, :alert => t('admin.dashboard.index.unknown_object')
  end

  protected

    def set_menu
      @menu = []
      @menu << { :name => 'overview', :controller => 'admin/dashboard', :link => '/' } if current_user.admin?
      @menu << { :name => 'users', :controller => 'admin/users', :link => '/admin/users' } if can? :manage, User
      @menu << { :name => 'vehicles', :controller => 'admin/vehicles', :link => '/admin/vehicles' }
      @menu << { :name => 'additional_users', :controller => 'admin/additional_users', :link => '/admin/additional_users' } if can? :manage_additional_users, User
      @menu << { :name => 'fuel_sensors', :controller => 'admin/fuel_sensors', :link => '/admin/fuel_sensors' } if can? :manage, FuelSensor
      @menu << { :name => 'sim_cards', :controller => 'admin/sim_cards', :link => '/admin/sim_cards' } if can? :manage, SimCard
      @menu << { :name => 'tools', :controller => 'admin/tools', :link => '/admin/tools' } if current_user.admin?
      @menu.each{ |item| item[:active] = true if params[:controller] == item[:controller] }
    end

    def set_search
      # TODO: implement
      @show_search = false
    end

    def set_sidebar_actions
      @sidebar_actions = []
    end

    def get_list_sort_state(columns, list_name, defaults = {})
      sort_state = {}

      sort_state[:dir] = params[:sort_dir] || session["#{list_name}_sort_dir"]
      sort_state[:dir] = %w{ asc desc }.include?(sort_state[:dir]) ? sort_state[:dir] : defaults[:dir]
      session["#{list_name}_sort_dir"] = sort_state[:dir]

      sort_state[:field] = params[:sort_field] || session["#{list_name}_sort_field"]
      sort_state[:field] = columns.include?(sort_state[:field]) ? sort_state[:field] : defaults[:field]
      session["#{list_name}_sort_field"] = sort_state[:field]

      sort_state
    end

    def get_list_page
      page = params[:page].to_i
      page > 0 ? page : 1
    end

    def get_map_api_key(vendor, host)
      dev_request = AppConfig.host.development == host
      @api_key = AppConfig.maps.send(vendor.to_s).send('api_key' + (dev_request ? '_dev' : ''))
    end

end
