module Admin::VehiclesHelper

  def timeframe(movement)
    "#{movement.from_time.to_formatted_s(:time)} - #{movement.to_time.to_formatted_s(:time)}"
  end

end
