class User < ActiveRecord::Base

  validates :login, :presence => true, :uniqueness => true, :length => { :minimum => 3 }
  devise :database_authenticatable, :rememberable, :trackable, :validatable
  attr_accessible :login, :name, :email, :password, :password_confirmation, :remember_me
  validates :password, :presence => true, :confirmation => true, :on => :create

  protected

    def email_required?
      false
    end

end
