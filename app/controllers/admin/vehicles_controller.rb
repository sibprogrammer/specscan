class Admin::VehiclesController < Admin::Base

  before_filter :check_manage_permission, :only => [:new, :create, :destroy]
  before_filter :set_selected_vehicle, :only => [:show, :edit, :update, :map, :reports, :day_report, :destroy, :get_movement_points]

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
    @show_last_point = Date.today.to_time == time

    @api_key = get_map_api_key :yandex, request.host
    @movements = Movement.where(:imei => @vehicle.imei, :from_timestamp.gte => time.to_i, :from_timestamp.lte => time.to_i + 86400).
      sort(:from_timestamp)
    @last_point = WayPoint.where(:imei => @vehicle.imei, :coors_valid => true, :timestamp.lte => time.to_i + 86400).sort(:timestamp.desc).first

    @js_locale_keys = %w{ time speed }
  end

  def get_movement_points
    movement = Movement.where(:imei => @vehicle.imei, '_id' => params[:movement_id]).first
    render :json => movement ? movement.get_points : []
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
    @reports_summary = get_reports_summary(@reports)
  end

  def day_report
    time = params.key?(:date) ? Time.parse(params[:date]) : Date.today.to_time
    @selected_date = time.to_formatted_s(:date)
    @week_day = t('week_day.name_' + time.wday.to_s)

    @movements = Movement.where(:imei => @vehicle.imei, :from_timestamp.gte => time.to_i, :from_timestamp.lte => time.to_i + 86400).
      sort(:from_timestamp)
    @movements_ranges = movements_ranges(@movements, time)
    @first_movement, @last_movement = get_boundary_movements(@movements)
    @report = Report.where(:imei => @vehicle.imei, :date => time.to_date.strftime('%Y%m%d').to_i).first

    @js_locale_keys = %w{ parking_title movement_title reset_zoom reset_zoom_title }
  end

  def destroy
    @vehicle.destroy
    redirect_to(admin_vehicles_path, :notice => t('admin.vehicles.destroy.vehicle_deleted'))
  end

  private

    def check_manage_permission
      authorize! :manage, Vehicle
    end

    def set_selected_vehicle
      @vehicle = Vehicle.find(params[:id])
      authorize! :edit, @vehicle
    end

    def get_boundary_movements(movements)
      movements = movements.find_all{ |movement| !movement.parking? }
      [nil, nil] if movements.blank?
      [movements.first, movements.last]
    end

    def movements_ranges(movements, day_start_time)
      ranges = []
      movements.each do |movement|
        next if movement.parking?
        from_time = (movement.from_time - day_start_time) / 60
        to_time = (movement.to_time - day_start_time) / 60
        ranges << [from_time.to_i, to_time.to_i]
      end
      ranges
    end

    def get_reports_summary(reports)
      fields = %w{ movement_count movement_time parking_count parking_time distance fuel_norm }

      reports_summary = {}
      fields.each{ |field| reports_summary[field.to_sym] = 0 }

      reports.each do |reports|
        fields.each{ |field| reports_summary[field.to_sym] += reports.send(field) }
      end

      reports_summary
    end

end
