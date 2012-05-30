class CreateFuelSensors < ActiveRecord::Migration
  def change
    create_table :fuel_sensors do |t|
      t.integer :fuel_sensor_model_id
      t.string :code
      t.string :comments
      t.timestamps
    end
  end
end
