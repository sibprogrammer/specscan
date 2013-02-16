class Ability

  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user (not logged in)

    if user.admin?
      can :manage, :all
      can :manage_additional_users, User
      can :manage, Driver
    end

    if user.client?
      can :edit, Vehicle, :user_id => user.id
      can :view, Vehicle, :user_id => user.id
      can :edit, User, :owner_id => user.id
      can :view, Driver, :owner_id => user.id
      can :edit, Driver, :owner_id => user.id
      can :manage, Driver, :owner_id => user.id
      can :manage_additional_users, User
    end

    if user.user?
      can :view, Vehicle do |vehicle|
         vehicle.user_id == user.owner_id or (user.owner and user.owner.admin?)
      end

      can :view, Driver do |driver|
        driver.owner_id == user.owner_id or (user.owner and user.owner.admin?)
      end
    end
  end

end
