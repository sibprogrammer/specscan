class Api::Base < ApplicationController

  before_filter :authenticate
  respond_to :json

  protected

    def current_user
      @current_user
    end

  private

    def authenticate
      if user = authenticate_with_http_basic { |login, password| User.authenticate(login, password) }
        @current_user = user
      else
        request_http_basic_authentication
      end
    end

end
