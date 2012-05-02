class Admin::DashboardController < Admin::Base

  def index
    redirect_to admin_vehicles_path unless current_user.admin?
    @users_total = User.count(:all) if can? :manage, User
    @vehicles_total = can?(:manage, Vehicle) ? Vehicle.count(:all) : current_user.vehicles.count
    @sim_cards_total = SimCard.count(:all) if can? :manage, SimCard
  end

end
