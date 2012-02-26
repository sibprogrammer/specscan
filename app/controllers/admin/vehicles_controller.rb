class Admin::VehiclesController < Admin::Base

  menu_section :vehicles
  before_filter :check_manage_permission, :only => [:new, :create, :edit, :update]
  before_filter :set_selected_vehicle, :only => [:show, :edit, :update, :map, :reports]

  def index
    conditions = { :order => 'created_at DESC' }
    @vehicles = can?(:manage, Vehicle) ? Vehicle.all(conditions) : current_user.vehicles(conditions)
  end

  def show
  end

  def new
    @vehicle = Vehicle.new
  end

  def create
    @vehicle = Vehicle.new(params[:vehicle])

    if @vehicle.save
      redirect_to(admin_vehicles_path, :notice => t('admin.vehicles.create.vehicle_created'))
    else
      render :action => 'new'
    end
  end

  def edit
  end

  def update
    if @vehicle.update_attributes(params[:vehicle])
      redirect_to(admin_vehicles_path, :notice => t('admin.vehicles.update.vehicle_updated'))
    else
      render :action => 'edit'
    end
  end

  def map
    lan_request = 'spec.rails3.lan' == request.host
    @api_key = AppConfig.maps.yandex.send('api_key' + (lan_request ? '_local' : ''))

    @movements = Movement.where(:imei => @vehicle.imei).sort(:to_timestamp.desc).limit(20)
  end

  def reports
  end

  private

    def check_manage_permission
      authorize! :manage, Vehicle
    end

    def set_selected_vehicle
      @vehicle = Vehicle.find(params[:id])
      authorize! :read, @vehicle
    end

end
