class User < ActiveRecord::Base

  ROLE_ADMIN = 1
  ROLE_CLIENT = 2
  ROLE_USER = 3
  ROLES = [['admin', ROLE_ADMIN], ['client', ROLE_CLIENT], ['user', ROLE_USER]]

  validates :login, :presence => true, :uniqueness => true, :length => { :minimum => 3, :maximum => 20 },
    :format => { :with => /^[-a-z\d]+$/ }
  validates :password, :presence => true, :confirmation => true, :on => :create,
    :length => { :minimum => 6, :maximum => 25 }, :format => { :with => /^[a-zA-Z\d]+$/ }
  validates :role, :presence => true
  devise :database_authenticatable, :rememberable, :trackable, :validatable
  attr_accessible :login, :name, :email, :password, :password_confirmation, :remember_me, :role, :contact_name,
    :phone, :additional_info, :comment, :owner_id

  has_many :vehicles, :order => 'name'
  belongs_to :owner, :class_name => 'User', :foreign_key => 'owner_id'
  has_many :additional_users, :class_name => 'User', :foreign_key => 'owner_id', :dependent => :destroy
  has_many :drivers, :foreign_key => 'owner_id', :dependent => :destroy

  scope :clients, where('role IN (?)', [User::ROLE_CLIENT, User::ROLE_ADMIN]).order('login') 
  scope :recently, order('created_at DESC')

  def admin?
    ROLE_ADMIN == role
  end

  def client?
    ROLE_CLIENT == role
  end

  def user?
    ROLE_USER == role
  end

  def role_name
    case role
      when ROLE_ADMIN then 'admin'
      when ROLE_CLIENT then 'client'
      when ROLE_USER then 'user'
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
    super && unlocked && (owner ? owner.unlocked : true)
  end

  def deletable?
    user? or 0 == vehicles.count
  end

  def self.authenticate(login, password)
    user = self.find_by_login(login)
    return false unless user
    return false unless user.valid_password?(password)
    user
  end

  protected

    def email_required?
      false
    end

end
