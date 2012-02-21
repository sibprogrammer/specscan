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
      @menu << { :name => 'overview', :link => '/' }
      @menu << { :name => 'users', :link => '/admin/users' } if can? :manage, User
      @menu << { :name => 'vehicles', :link => '/admin/vehicles' }
      @menu << { :name => 'logout', :link => '/logout' }
      @menu_section = @@menu_section
    end

    def set_search
      # TODO: implement
      @show_search = false
    end

    def set_sidebar_actions
      @sidebar_actions = []
    end

    def self.menu_section(section)
      @@menu_section = section.to_s
    end

end
