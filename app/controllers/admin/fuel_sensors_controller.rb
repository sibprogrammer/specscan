class Admin::FuelSensorsController < Admin::Base

  before_filter :check_manage_permission
  before_filter :set_selected_fuel_sensor, :only => [:show, :edit, :update, :destroy]

  def index
    @columns = %w{ id fuel_sensor_model_id code comments created_at }
    @sort_state = get_list_sort_state(@columns, :fuel_sensors_list, :dir => 'desc', :field => 'created_at')
    order = "#{@sort_state[:field]} #{@sort_state[:dir]}"
    @fuel_sensors = FuelSensor.page(params[:page]).order(order)
  end

  def show
  end

  def new
    @fuel_sensor = FuelSensor.new
  end

  def create
    @fuel_sensor = FuelSensor.new(params[:fuel_sensor])

    if @fuel_sensor.save
      redirect_to(admin_fuel_sensors_path, :notice => t('admin.fuel_sensors.create.fuel_sensor_created'))
    else
      render :action => 'new'
    end
  end

  def update
    if @fuel_sensor.update_attributes(params[:fuel_sensor])
      redirect_to(admin_fuel_sensor_path(@fuel_sensor), :notice => t('admin.fuel_sensors.update.fuel_sensor_updated', :title => @fuel_sensor.code))
    else
      render :action => 'edit'
    end
  end

  def destroy
    @fuel_sensor.destroy
    redirect_to(admin_fuel_sensors_path, :notice => t('admin.fuel_sensors.destroy.fuel_sensor_deleted'))
  end

  private

    def check_manage_permission
      authorize! :manage, FuelSensor
    end

    def set_selected_fuel_sensor
      @fuel_sensor = FuelSensor.find(params[:id])
      authorize! :edit, @fuel_sensor
    end

end
