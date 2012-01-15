class Admin::Base < ApplicationController

  layout 'admin'
  before_filter :authenticate_user!, :set_menu, :set_search

  protected

    def set_menu
      @menu = [{
        :name => 'overview',
        :link => '/',
      }, {
        :name => 'users',
        :link => '/admin/users/list',
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

    def self.menu_section(section)
      @@menu_section = section.to_s
    end

end
