class AddMinParkingTimeToVehicles < ActiveRecord::Migration
  def change
    add_column :vehicles, :min_parking_time, :integer
  end
end
