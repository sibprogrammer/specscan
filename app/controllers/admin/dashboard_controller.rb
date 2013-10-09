class Admin::DashboardController < Admin::Base

  def index
    redirect_to admin_vehicles_path unless current_user.admin?

    @clients_total = User.where(:role => User::ROLE_CLIENT).count if can? :manage, User
    @vehicles_total = can?(:manage, Vehicle) ? Vehicle.count(:all) : current_user.vehicles.count
    @plans_total = Plan.count(:all) if can? :manager, Plan
    @additional_users_total = User.where(:role => User::ROLE_USER).count if can? :manage, User
    @drivers_total = Driver.count(:all) if can? :manage, User
    @sim_cards_total = SimCard.count(:all) if can? :manage, SimCard
    @fuel_sensors_total = FuelSensor.count(:all) if can? :manage, FuelSensor

    @way_points_total = WayPoint.count
    @way_points_last_day = WayPoint.count(:timestamp => { '$gte' => (Time.now.to_i - 24.hours.to_i) })
    @movements_total = Movement.count
    @reports_total = Report.count
    @fuel_changes_total = FuelChange.count
    @activities_total = Activity.count
    @locations_total = Location.count

    @events = ActionLog.sort(:$natural.desc).limit(4).all
  end

end
