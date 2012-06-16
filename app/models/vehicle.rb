class Vehicle < ActiveRecord::Base

  validates :imei, :uniqueness => true, :allow_blank => true, :length => { :in => 5..50 },
    :numericality => { :only_integer => true }
  validates :user_id, :presence => true
  validates :reg_number, :length => { :in => 3..15 }, :allow_blank => true
  validates :name, :presence => true, :uniqueness => { :scope => :user_id }
  validates :vehicle_type_id, :presence => true

  attr_accessible :imei, :user_id, :reg_number, :name, :description, :tracker_model_id, :fuel_norm, :fuel_tank, :fuel_tank2,
    :calibration_table, :calibration_table2, :vehicle_type_id

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

  def get_fuel_amount(signal)
    return 0 if !self.fuel_sensor or fuel_tank.blank? or calibration_table.blank?

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
    way_point = WayPoint.get_by_timestamp(timestamp, imei)
    return 0 unless way_point
    get_fuel_amount(way_point.fuel_signal)
  end

end
