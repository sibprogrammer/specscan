class Admin::VehiclesController < Admin::Base

  before_filter :check_manage_permission, :only => [:new, :create, :destroy, :calibration, :calibration_save, :clear, :clear_do]
  before_filter :check_edit_permission, :only => [:edit, :update]
  before_filter :set_selected_vehicle, :only => [:show, :edit, :update, :map, :reports, :day_report, :destroy, :get_movement_points,
    :calibration, :calibration_save, :get_last_point, :clear, :clear_do]

  def index
    @columns = %w{ name reg_number imei owner created_at }

    if can?(:manage, Vehicle) or (current_user.owner and current_user.owner.admin?)
      @sort_state = get_list_sort_state(@columns, :vehicles_admin_list, :dir => 'desc', :field => 'created_at')
      order = "#{@sort_state[:field]} #{@sort_state[:dir]}"
      @vehicles = Vehicle.page(params[:page]).joins(:user).select('vehicles.*, users.login as owner').order(order)
    else
      @sort_state = get_list_sort_state(@columns, :vehicles_list, :field => 'name')
      order = "#{@sort_state[:field]} #{@sort_state[:dir]}"
      user = current_user.user? ? current_user.owner : current_user
      @vehicles = user.vehicles.page(params[:page]).order(order)
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
    manager_only_fields = %w{ imei user_id tracker_model_id comment debt retranslate }
    manager_only_fields.each{ |field| params[:vehicle].delete(field.to_sym) } unless can? :manage, @vehicle

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
    @movements = Movement.where(:imei => @vehicle.imei, :from_timestamp.gte => time.to_i, :from_timestamp.lt => time.to_i + 86400).
      sort(:from_timestamp)
    @last_point = WayPoint.where(:imei => @vehicle.imei, :coors_valid => true, :timestamp.lt => time.to_i + 86400).sort(:timestamp.desc).first

    @js_locale_keys = %w{ time speed }
  end

  def overview_map
    @api_key = get_map_api_key :yandex, request.host

    if can?(:manage, Vehicle) or (current_user.owner and current_user.owner.admin?)
      @vehicles = Vehicle.all(:order => 'name')
    else
      user = current_user.user? ? current_user.owner : current_user
      @vehicles = user.vehicles
    end
  end

  def get_movement_points
    movement = Movement.where(:imei => @vehicle.imei, '_id' => params[:movement_id]).first
    render :json => movement ? movement.get_points : []
  end

  def get_last_point
    @last_point = WayPoint.where(:imei => @vehicle.imei, :coors_valid => true).sort(:timestamp.desc).first
    render :json => { :latitude => @last_point.latitude, :longitude => @last_point.longitude }
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
    @selected_month = (params.key?(:date) ? Date.parse(params[:date]) : Date.today).strftime('%Y.%m.01')
    @reports = Report.where(:imei => @vehicle.imei, :date.gte => (month + '01').to_i, :date.lte => (month + '31').to_i).sort(:date.desc)
    @reports_summary = get_reports_summary(@reports, @vehicle)

    respond_to do |format|
      format.html
      format.xls if params[:format] == 'xls'
    end
  end

  def day_report
    time = params.key?(:date) ? Time.parse(params[:date]) : Date.today.to_time
    @selected_date = time.to_formatted_s(:date)
    @week_day = t('week_day.name_' + time.wday.to_s)
    @selected_date_last_minute = ((Time.now.to_i - time.to_i) < 86400 ? (Time.now.to_i - time.to_i) : 86400) / 60

    @movements = Movement.where(:imei => @vehicle.imei, :from_timestamp.gte => time.to_i, :from_timestamp.lt => time.to_i + 86400).
      sort(:from_timestamp)
    @movements_ranges = movements_ranges(@movements, time)
    @first_movement, @last_movement = get_boundary_movements(@movements)

    if @vehicle.has_activity_sensor?
      activities = Activity.where(:imei => @vehicle.imei, :from_timestamp.gte => time.to_i, :from_timestamp.lt => time.to_i + 86400).
        sort(:from_timestamp)
      @activities_ranges = activities_ranges(activities, time)
    end

    @report = Report.where(:imei => @vehicle.imei, :date => time.to_date.strftime('%Y%m%d').to_i).first
    @fuel_changes = FuelChange.where(:imei => @vehicle.imei, :from_timestamp.gte => time.to_i, :from_timestamp.lt => time.to_i + 86400).
      sort(:from_timestamp)
    @fuel_chart_data = get_fuel_details(time, @selected_date_last_minute)

    @js_locale_keys = %w{ parking_title movement_title activity_title reset_zoom reset_zoom_title }

    respond_to do |format|
      format.html
      format.xls if params[:format] == 'xls'
    end
  end

  def destroy
    @vehicle.destroy
    redirect_to(admin_vehicles_path, :notice => t('admin.vehicles.destroy.vehicle_deleted'))
  end

  def calibration
  end

  def calibration_save
    attributes = {
      :calibration_table => params[:vehicle][:calibration_table],
      :calibration_table2 => params[:vehicle][:calibration_table2],
    }

    if @vehicle.update_attributes(attributes)
      redirect_to(admin_vehicle_path(@vehicle), :notice => t('admin.vehicles.calibration_save.updated'))
    else
      render :action => 'calibration'
    end
  end

  def clear
  end

  def clear_do
    WayPoint.delete_all(:imei => @vehicle.imei) if params.key?(:way_points)
    Movement.delete_all(:imei => @vehicle.imei) if params.key?(:movements)
    Report.delete_all(:imei => @vehicle.imei) if params.key?(:reports)
    Activity.delete_all(:imei => @vehicle.imei) if params.key?(:activities)
    if params.key?(:fuel_changes)
      FuelChange.delete_all(:imei => @vehicle.imei)
      Movement.unset({ :imei => @vehicle.imei }, :fuel_last_update_timestamp)
      Movement.unset({ :imei => @vehicle.imei }, :fuel_used)
    end
    redirect_to(admin_vehicle_path(@vehicle), :notice => t('admin.vehicles.clear_do.cleared'))
  end

  private

    def check_manage_permission
      authorize! :manage, Vehicle
    end

    def check_edit_permission
      authorize! :edit, Vehicle
    end

    def set_selected_vehicle
      @vehicle = Vehicle.find(params[:id])
      authorize! :view, @vehicle
    end

    def get_boundary_movements(movements)
      movements = movements.find_all{ |movement| !movement.parking? }
      [nil, nil] if movements.blank?
      [movements.first, movements.last]
    end

    def movements_ranges(movements, day_start_time)
      ranges = []
      movements.each do |movement|
        from_time = (movement.from_time - day_start_time) / 60
        to_time = (movement.to_time - day_start_time) / 60
        ranges << [
          from_time.to_i,
          to_time.to_i,
          movement.parking? ? 0 : 1,
          movement.id
        ]
      end
      ranges
    end

    def activities_ranges(activities, day_start_time)
      ranges = []
      activities.each do |activity|
        from_time = (activity.from_time - day_start_time) / 60
        to_time = (activity.to_time - day_start_time) / 60
        ranges << [
          from_time.to_i,
          to_time.to_i,
          activity.active ? 1 : 0,
        ]
      end
      ranges
    end

    def get_reports_summary(reports, vehicle)
      fields = %w{ movement_count movement_time parking_count parking_time distance fuel_norm active_time }
      fields << 'fuel_used' << 'fuel_added' << 'fuel_stolen' if vehicle.fuel_sensor

      reports_summary = {}
      fields.each{ |field| reports_summary[field.to_sym] = 0 }

      reports.each do |report|
        fields.each do |field|
          if %w{ fuel_norm fuel_used fuel_added fuel_stolen }.include?(field)
            reports_summary[field.to_sym] += report.send(field).to_f
          else
            reports_summary[field.to_sym] += report.send(field).to_i
          end
        end
      end

      static_work_time = reports_summary[:active_time] - reports_summary[:movement_time]
      reports_summary[:static_work_time] = (static_work_time > 0) ? static_work_time : 0

      reports_summary
    end

    def get_fuel_details(start_time, selected_date_last_minute)
      return [] unless @vehicle.fuel_sensor

      if ('native' == @vehicle.fuel_sensor.fuel_sensor_model.code)
        signal_field = :power_input_1
        info_fields = signal_field, :timestamp, :power_input_0
      else
        signal_field = :rs232_1
        info_fields = signal_field, :timestamp
      end

      fuel_initial_value = @vehicle.fuel_by_time(start_time.to_i)

      way_points = WayPoint.where(:imei => @vehicle.imei, :timestamp.gte => start_time.to_i, :timestamp.lt => start_time.to_i + 86400).
        fields(info_fields).sort(:timestamp)
      fuel_values = {}
      last_fuel_value = fuel_initial_value

      way_points.each do |way_point|
        next if 0 == way_point.send(signal_field)
        fuel_value = @vehicle.get_fuel_amount(way_point).to_i
        next if 0 == fuel_value
        time_offset = (way_point.timestamp - start_time.to_i) / 60
        fuel_values[time_offset] = fuel_values[time_offset] ? ((fuel_values[time_offset] + fuel_value) / 2) : fuel_value
        last_fuel_value = fuel_value
      end

      fuel_values.keys.sort.each{ |key| logger.info "fuel_values: #{fuel_values[key]}" }

      fuel_values[selected_date_last_minute] = last_fuel_value
      fuel_values = approximate(fuel_values) if (fuel_values.length >= 5) and ('native' == @vehicle.fuel_sensor.fuel_sensor_model.code)

      minutes = fuel_values.keys.sort
      prev_minute = 0
      prev_fuel_value = fuel_values[minutes.first]
      data = []

      minutes.each do |minute|
        prev_minute.upto(minute-1).each{ |current_minute| data << prev_fuel_value }
        prev_minute = minute
        prev_fuel_value = fuel_values[minute]
      end

      data
    end

    def approximate(values_hash)
      data = []
      values_hash.keys.sort.each{ |index| data << [index, values_hash[index]] }

      approx_data = {}

      data.each_with_index do |value, index|
        key, value = value
        if 0 == index
          approx_data[key] = (3*data[0].last + 2*data[1].last + data[2].last - data[4].last) / 5
          next
        end

        if 1 == index
          approx_data[key] = (4*data[0].last + 3*data[1].last + 2*data[2].last + data[3].last) / 10
          next
        end

        if index == (data.length-2)
          approx_data[key] = (4*data[index].last + 3*data[index-1].last + 2*data[index-2].last + data[index-3].last) / 10
          next
        end

        if index == (data.length-1)
          approx_data[key] = (3*data[index].last + 2*data[index-1].last + data[index-2].last - data[index-4].last) / 5
          next
        end

        approx_value = 0
        -2.upto(2).each{ |shift| approx_value += data[index+shift].last }
        approx_data[key] = approx_value / 5
      end

      approx_data
    end

end
