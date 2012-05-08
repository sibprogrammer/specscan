class User < ActiveRecord::Base

  ROLE_ADMIN = 1
  ROLE_CLIENT = 2
  ROLES = [['admin', ROLE_ADMIN], ['client', ROLE_CLIENT]]

  validates :login, :presence => true, :uniqueness => true, :length => { :minimum => 3, :maximum => 15 },
    :format => { :with => /^[a-z\d]+$/ }
  validates :password, :presence => true, :confirmation => true, :on => :create,
    :length => { :minimum => 6, :maximum => 25 }, :format => { :with => /^[a-zA-Z\d]+$/ }
  validates :role, :presence => true
  devise :database_authenticatable, :rememberable, :trackable, :validatable
  attr_accessible :login, :name, :email, :password, :password_confirmation, :remember_me, :role, :contact_name,
    :phone, :additional_info, :comment

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

  def login=(value)
    write_attribute :login, (value ? value.downcase : nil)
  end

  def lock
    self.locked = true
    save
  end

  def unlock
    self.locked = false
    save
  end

  def unlocked
    !locked
  end

  def active_for_authentication?
    super && unlocked
  end

  def deletable?
    0 == vehicles.count
  end

  protected

    def email_required?
      false
    end

end
