class AddDebtToVehicles < ActiveRecord::Migration
  def change
    add_column :vehicles, :debt, :integer, :default => 0
  end
end
