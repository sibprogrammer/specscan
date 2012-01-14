class Admin::Base < ApplicationController

  before_filter :set_menu

  protected

    def set_menu
      @menu = [{
        :name => 'overview',
        :link => '/admin/dashboard',
      }, {
        :name => 'clients',
        :link => '/admin/clients/list',
      }, {
        :name => 'resellers',
        :link => '/admin/reseller',
      }, {
        :name => 'cars',
        :link => '/admin/cars',
      }, {
        :name => 'settings',
        :link => '/admin/settings',
      }, {
        :name => 'support',
        :link => '/admin/tickets',
      }, {
        :name => 'logout',
        :link => '/sessions/logout'
      }]
      @menu_section = @@menu_section
    end

    def self.menu_section(section)
      @@menu_section = section.to_s
    end

end
