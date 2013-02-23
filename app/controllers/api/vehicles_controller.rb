class Api::VehiclesController < Api::Base

  before_filter :set_selected_vehicle, :only => [:location]

  def index
    owner = current_user.user? ? current_user.owner : current_user
    @vehicles = owner.vehicles
  end

  def location
    @point = @vehicle.last_point
  end

  private

    def set_selected_vehicle
      @vehicle = Vehicle.find(params[:id])
      authorize! :view, @vehicle
    end

end
