class AddTrackerToVehicles < ActiveRecord::Migration
  def change
    add_column :vehicles, :tracker_model_id, :integer, :default => 0
  end
end
