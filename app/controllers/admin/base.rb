class Admin::Base < ApplicationController

  layout 'admin'
  before_filter :authenticate_user!, :set_menu, :set_search, :set_sidebar_actions

  protected

    def set_menu
      @menu = [{
        :name => 'overview',
        :link => '/',
      }, {
        :name => 'users',
        :link => '/admin/users',
      }, {
        :name => 'cars',
        :link => '/admin/cars',
      }, {
        :name => 'logout',
        :link => '/logout'
      }]
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
