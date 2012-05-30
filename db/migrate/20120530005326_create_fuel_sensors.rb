class CreateFuelSensors < ActiveRecord::Migration
  def change
    create_table :fuel_sensors do |t|
      t.integer :fuel_sensor_model_id
      t.string :code
      t.string :comments
      t.integer :vehicle_id
      t.timestamps
    end
  end
end
