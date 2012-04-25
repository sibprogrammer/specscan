class Admin::DashboardController < Admin::Base

  def index
    @users_total = User.count(:all) if can? :manage, User
    @vehicles_total = can?(:manage, Vehicle) ? Vehicle.count(:all) : current_user.vehicles.count
  end

end
