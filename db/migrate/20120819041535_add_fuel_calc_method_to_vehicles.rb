class AddFuelCalcMethodToVehicles < ActiveRecord::Migration
  def change
    add_column :vehicles, :fuel_calc_method, :integer, :default => 1
  end
end
