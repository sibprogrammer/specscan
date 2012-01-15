class Admin::Base < ApplicationController

  layout 'admin'
  before_filter :authenticate_user!, :set_menu, :set_search

  protected

    def set_menu
      @menu = [{
        :name => 'overview',
        :link => '/',
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
        :link => '/logout'
      }]
      @menu_section = @@menu_section
    end

    def set_search
      @show_search = true
    end

    def self.menu_section(section)
      @@menu_section = section.to_s
    end

end
