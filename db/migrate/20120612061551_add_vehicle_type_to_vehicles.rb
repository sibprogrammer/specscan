class AddVehicleTypeToVehicles < ActiveRecord::Migration
  def change
    default_vehicle_type_id = VehicleType.find_by_code('other').id
    
    add_column :vehicles, :vehicle_type_id, :integer, :default => default_vehicle_type_id
  end
end
