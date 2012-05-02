class Admin::VehiclesController < Admin::Base

  before_filter :check_manage_permission, :only => [:new, :create]
  before_filter :set_selected_vehicle, :only => [:show, :edit, :update, :map, :reports]

  def index
    @columns = %w{ name reg_number imei owner created_at }
    @sort_state = get_list_sort_state(@columns, :users_list, :dir => 'desc', :field => 'created_at')
    order = "#{@sort_state[:field]} #{@sort_state[:dir]}"
    if can?(:manage, Vehicle)
      @vehicles = Vehicle.page(params[:page]).joins(:user).select('vehicles.*, users.login as owner').order(order)
    else
      @vehicles = current_user.vehicles.page(params[:page]).order(order)
    end
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
    params[:vehicle].delete(:imei) unless can? :manage, @vehicle
    params[:vehicle].delete(:user_id) unless can? :manage, @vehicle
    params[:vehicle].delete(:tracker_model_id) unless can? :manage, @vehicle

    if @vehicle.update_attributes(params[:vehicle])
      redirect_to(admin_vehicle_path(@vehicle), :notice => t('admin.vehicles.update.vehicle_updated'))
    else
      render :action => 'edit'
    end
  end

  def map
    time = params.key?(:date) ? Time.parse(params[:date]) : Date.today.to_time
    @selected_date = time.to_formatted_s(:date)

    @api_key = get_map_api_key :yandex, request.host
    @movements = Movement.where(:imei => @vehicle.imei, :from_timestamp.gte => time.to_i, :from_timestamp.lte => time.to_i + 86400).
      sort(:from_timestamp.desc)
    @last_point = WayPoint.where(:imei => @vehicle.imei, :coors_valid => true, :timestamp.lte => time.to_i + 86400).sort(:timestamp.desc).first
  end

  def reports
    @months = []
    (0..2).each do |index|
      @months << {
        :name => t('month.name_' + (Date.today - index.month).month.to_s),
        :date => (Date.today - index.month).strftime('%Y.%m.01')
      }
    end

    month = (params.key?(:date) ? Date.parse(params[:date]) : Date.today).strftime('%Y%m')
    @reports = Report.where(:imei => @vehicle.imei, :date.gte => (month + '01').to_i, :date.lte => (month + '31').to_i).sort(:date.desc)
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
