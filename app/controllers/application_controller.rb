class ApplicationController < ActionController::Base

  protect_from_forgery
  before_filter :set_menu

  protected

    def set_menu
      @menu = []
    end

  private

    def after_sign_out_path_for(resource_or_scope)
      new_user_session_path
    end

end
