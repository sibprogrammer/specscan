class Ability

  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user (not logged in)
    
    if user.admin?
      can :manage, :all
    else
      can :read, Vehicle, :user_id => user.id
    end
  end

end
