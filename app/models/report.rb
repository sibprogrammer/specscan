class Report

  include MongoMapper::Document

  key :date
  key :imei
  key :parking_count
  key :movement_count
  key :parking_time
  key :movement_time
  key :distance
  key :fuel_norm
  key :fuel_used
  key :active_time

  def date_human
    Date.parse(date.to_s).to_formatted_s(:date)
  end

  def static_work_time
    time = active_time - movement_time
    time > 0 ? time : 0
  end

end
