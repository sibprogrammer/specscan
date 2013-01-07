class AddRetranslateToVehicles < ActiveRecord::Migration
  def change
    add_column :vehicles, :retranslate, :boolean, :default => false
  end
end
