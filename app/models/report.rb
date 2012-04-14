class Report

  include MongoMapper::Document

  key :date
  key :imei
  key :parking_count
  key :movement_count
  key :parking_time
  key :movement_time
  key :distance

  def date_human
    Date.parse(date.to_s).to_formatted_s(:date)
  end

end
