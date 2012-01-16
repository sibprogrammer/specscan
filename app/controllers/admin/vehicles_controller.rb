class Admin::VehiclesController < Admin::Base

  menu_section :vehicles

  def index
    @vehicles = Vehicle.all

    @sidebar_actions = [{
      :title => t('admin.vehicles.index.action.add_vehicle'),
      :link => new_admin_vehicle_path
    }]
  end

  def show
    @vehicle = Vehicle.find(params[:id])
  end

end
