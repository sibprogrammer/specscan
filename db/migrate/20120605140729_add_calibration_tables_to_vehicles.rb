class AddCalibrationTablesToVehicles < ActiveRecord::Migration
  def change
    add_column :vehicles, :calibration_table, :text
    add_column :vehicles, :calibration_table2, :text
  end
end
