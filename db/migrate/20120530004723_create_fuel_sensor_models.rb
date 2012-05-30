class CreateFuelSensorModels < ActiveRecord::Migration
  def change
    create_table :fuel_sensor_models do |t|
      t.string :title
      t.string :description
    end
  end
end
