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

  attr_accessible :imei, :user_id, :reg_number, :name, :description, :tracker_model_id, :fuel_norm, :fuel_tank, :fuel_tank2,
    :calibration_table, :calibration_table2, :vehicle_type_id, :fuel_calc_method, :comment, :debt, :distance_multiplier

  belongs_to :user
  belongs_to :tracker_model
  has_one :fuel_sensor
  has_one :sim_card
  belongs_to :vehicle_type

  scope :with_imei, where("imei != ''")

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

end
