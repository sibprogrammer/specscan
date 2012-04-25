class AddFuelNormToVehicles < ActiveRecord::Migration
  def change
    add_column :vehicles, :fuel_norm, :decimal
  end
end
