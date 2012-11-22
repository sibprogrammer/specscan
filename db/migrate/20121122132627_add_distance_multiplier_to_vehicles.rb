class AddDistanceMultiplierToVehicles < ActiveRecord::Migration
  def change
    add_column :vehicles, :distance_multiplier, :decimal
  end
end
