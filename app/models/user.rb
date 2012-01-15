class User < ActiveRecord::Base
  devise :database_authenticatable, :rememberable, :trackable, :validatable

  attr_accessible :login, :password, :password_confirmation, :remember_me

  protected

    def email_required?
      false
    end

end
