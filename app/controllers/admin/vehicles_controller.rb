class Admin::VehiclesController < Admin::Base

  menu_section :vehicles
  before_filter :check_manage_permission, :only => [:new, :create]
  before_filter :set_selected_vehicle, :only => [:show, :edit, :update, :map, :reports]

  def index
    order = 'created_at DESC'
    @vehicles = can?(:manage, Vehicle) ? Vehicle.page(params[:page]).order(order) : current_user.vehicles.page(params[:page]).order(order)
  end

  def show
  end

  def new
    user = params.key?(:user_id) ? User.find(params[:user_id]) : current_user
    generated_name = t('admin.vehicles.new.generated_name', :index => user.vehicles.count + 1)
    @vehicle = Vehicle.new(:user_id => user.id, :name => generated_name)
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
    params[:vehicle].delete(:imei)
    params[:vehicle].delete(:user_id) unless can? :manage, @vehicle

    if @vehicle.update_attributes(params[:vehicle])
      redirect_to(admin_vehicle_path(@vehicle), :notice => t('admin.vehicles.update.vehicle_updated'))
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
      authorize! :edit, @vehicle
    end

end
