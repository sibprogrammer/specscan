class AddFuelSensorToVehicles < ActiveRecord::Migration
  def change
    add_column :vehicles, :fuel_sensor_id, :integer
  end
end
