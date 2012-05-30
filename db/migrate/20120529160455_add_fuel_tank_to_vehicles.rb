class AddFuelTankToVehicles < ActiveRecord::Migration
  def change
    add_column :vehicles, :fuel_tank, :decimal
    add_column :vehicles, :fuel_tank2, :decimal
  end
end
