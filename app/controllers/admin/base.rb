class Admin::Base < ApplicationController

  layout 'admin'
  before_filter :authenticate_user!, :set_menu, :set_sidebar_actions, :set_billing_notifications

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
      unless current_user.admin?
        @menu << { :name => 'additional_users', :controller => 'admin/additional_users', :link => '/admin/additional_users' } if can? :manage_additional_users, User
        @menu << { :name => 'drivers', :controller => 'admin/drivers', :link => '/admin/drivers' }
      end
      @menu << { :name => 'fuel_sensors', :controller => 'admin/fuel_sensors', :link => '/admin/fuel_sensors' } if can? :manage, FuelSensor
      @menu << { :name => 'sim_cards', :controller => 'admin/sim_cards', :link => '/admin/sim_cards' } if can? :manage, SimCard
      @menu << { :name => 'plans', :controller => 'admin/plans', :link => '/admin/plans' } if can? :manage, Plan
      @menu << { :name => 'tools', :controller => 'admin/tools', :link => '/admin/tools' } if current_user.admin?
      @menu.each{ |item| item[:active] = true if params[:controller] == item[:controller] }
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

    def set_billing_notifications
      return if can?(:manage, Vehicle) or (current_user.owner and current_user.owner.admin?)
      user = current_user.user? ? current_user.owner : current_user
      debt = 0
      user.vehicles.each{ |vehicle| debt += vehicle.debt }
      flash.now[:alert] = t('admin.vehicles.index.debt_notice', :debt => debt) if debt >= AppConfig.billing.debt_notification_limit
    end

    def action_log(event_type, params = {})
      ActionLog.log(@current_user, event_type, params)
    end

end
