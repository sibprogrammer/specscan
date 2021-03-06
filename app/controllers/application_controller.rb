class ApplicationController < ActionController::Base

  protect_from_forgery
  before_filter :set_menu

  protected

    def set_menu
      @menu = []
    end

  private

    def after_sign_in_path_for(user)
      ActionLog.log(user.login, :login, :ip => request.remote_ip)
      root_path
    end

    def after_sign_out_path_for(resource_or_scope)
      new_user_session_path
    end

end
