class Vehicle < ActiveRecord::Base

  FUEL_CALC_BY_DISTANCE = 1
  FUEL_CALC_BY_MHOURS = 2

  validates :imei, :uniqueness => true, :allow_blank => true, :length => { :in => 5..50 },
    :numericality => { :only_integer => true }
  validates :user_id, :presence => true
  validates :reg_number, :length => { :in => 3..15 }, :allow_blank => true, :uniqueness => true
  validates :name, :presence => true
  validates :vehicle_type_id, :presence => true
  validates :fuel_calc_method, :inclusion => { :in => 1..2 }
  validates :debt, :numericality => true
  validates :distance_multiplier, :numericality => { :greater_than => 0, :less_than_or_equal_to => 1.2 }, :allow_blank => true
  validates :min_parking_time, :numericality => { :greater_than_or_equal_to => 10, :less_than_or_equal_to => 600 }, :allow_blank => true

  attr_accessible :imei, :user_id, :reg_number, :name, :description, :tracker_model_id, :fuel_norm, :fuel_tank, :fuel_tank2,
    :calibration_table, :calibration_table2, :vehicle_type_id, :fuel_calc_method, :comment, :debt, :distance_multiplier,
    :min_parking_time, :retranslate

  belongs_to :user
  belongs_to :tracker_model
  has_one :fuel_sensor
  has_one :sim_card
  belongs_to :vehicle_type
  has_many :drivers, :order => 'name'

  scope :with_imei, where("imei != ''")
  scope :recently, order('created_at DESC')
  scope :with_retranslate, where(:retranslate => true)

  def total_way_points
    WayPoint.where(:imei => imei).count
  end

  def tracker_name
    tracker_model ? tracker_model.title : ''
  end

  def title
    name + (reg_number.blank? ? '' : (', ' + reg_number))
  end

  def get_fuel_amount(way_point)
    return 0 if !self.fuel_sensor or fuel_tank.blank? or calibration_table.blank?

    if ('native' == fuel_sensor.fuel_sensor_model.code)
      if way_point.power_input_0.to_i < 10000
        return 0
      else
        signal = way_point.power_input_1.to_i * 15000 / way_point.power_input_0.to_i
      end
    else
      signal = way_point.rs232_1.to_i
    end

    if @signals_table.blank?
      @signals_table = { 0 => 0 }
      calibration_table.split("\n").each do |string|
        litres, signal_value = string.split(" - ")
        @signals_table[signal_value.to_i] = litres.to_f
      end
    end

    return @signals_table[signal] if @signals_table.has_key?(signal)

    signal_min = @signals_table.keys.min
    signal_max = @signals_table.keys.max

    @signals_table.keys.sort.reverse_each do |value|
      if value <= signal
        signal_min = value
        break
      end
    end

    @signals_table.keys.sort.each do |value|
      if value >= signal
        signal_max = value
        break
      end
    end

    signal = signal_min if signal < signal_min
    signal = signal_max if signal > signal_max

    return @signals_table[signal] if @signals_table.has_key?(signal)
    return 0 if (signal_max - signal_min) == 0

    value = @signals_table[signal_min] + ((@signals_table[signal_max] - @signals_table[signal_min]) / (signal_max - signal_min)) * (signal - signal_min)
    @signals_table[signal] = value
    value
  end

  def fuel_by_time(timestamp)
    if ('native' == fuel_sensor.fuel_sensor_model.code)
      way_point = WayPoint.get_by_timestamp(timestamp, imei, { :power_input_0.gt => 10000 })
    else
      way_point = WayPoint.get_by_timestamp(timestamp, imei, { :rs232_1.gt => 0 })
    end
    return 0 unless way_point
    get_fuel_amount(way_point)
  end

  def last_point
    WayPoint.where(:imei => imei, :coors_valid => true).sort(:timestamp.desc).limit(1).first
  end

  def last_movement
    Movement.where(:imei => imei).sort(:to_timestamp.desc).limit(1).first
  end

  def moving?
    movement = last_movement
    return false unless movement
    !movement.parking? and (Time.now.to_i - movement.to_timestamp < 1.hour)
  end

  def gsm_active?
    point = last_point
    return false unless point
    (Time.now.to_i - point.timestamp.to_i) < 10.minutes
  end

  def gps_active?
    point = last_point
    return false unless point
    gsm_active? and point.coors_valid
  end

  def has_fuel_analytics?
    fuel_sensor and ('native' != fuel_sensor.fuel_sensor_model.code)
  end

  def has_activity_sensor?
    tracker_model and %w{ galileo teltonika }.include?(tracker_model.code)
  end

  def points_to_retranslate(limit = 100)
    WayPoint.where({
      :imei => imei,
      :coors_valid => true,
      :timestamp.gt => 24.hours.ago.to_i
    }).sort(:timestamp.desc).limit(limit)
  end

end
