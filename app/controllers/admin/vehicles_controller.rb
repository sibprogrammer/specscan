class Admin::VehiclesController < Admin::Base

  menu_section :vehicles

  def index
    @vehicles = Vehicle.all
  end

  def show
    @vehicle = Vehicle.find(params[:id])
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
    @vehicle = Vehicle.find(params[:id])
  end

  def update
    @vehicle = Vehicle.find(params[:id])

    if @vehicle.update_attributes(params[:vehicle])
      redirect_to(admin_vehicles_path, :notice => t('admin.vehicles.update.vehicle_updated'))
    else
      render :action => 'edit'
    end
  end

  def map
    @vehicle = Vehicle.find(params[:id])
    lan_request = 'spec.rails3.lan' == request.host
    @api_key = AppConfig.maps.yandex.send('api_key' + (lan_request ? '_local' : ''))

    @points = WayPoint.where({
      :imei => @vehicle.imei,
      :coors_valid => true,
      :sens_moving => true,
      :speed => { :$ne => 0 }
    }).sort(:timestamp.desc).limit(500).all.collect{ |point| [point[:longitude], point[:latitude]] }

    @movements = Movement.sort(:to_timestamp.desc).limit(20)
  end

end
