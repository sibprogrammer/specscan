class User < ActiveRecord::Base

  ROLE_ADMIN = 1
  ROLE_CLIENT = 2
  ROLES = [['admin', ROLE_ADMIN], ['client', ROLE_CLIENT]]

  validates :login, :presence => true, :uniqueness => true, :length => { :minimum => 3 }
  devise :database_authenticatable, :rememberable, :trackable, :validatable
  attr_accessible :login, :name, :email, :password, :password_confirmation, :remember_me, :role
  validates :password, :presence => true, :confirmation => true, :on => :create

  has_many :vehicles

  def admin?
    ROLE_ADMIN == role
  end

  def client?
    ROLE_CLIENT == role
  end

  def role_name
    case role
      when ROLE_ADMIN then 'admin'
      when ROLE_CLIENT then 'client'
    end
  end

  protected

    def email_required?
      false
    end

end
