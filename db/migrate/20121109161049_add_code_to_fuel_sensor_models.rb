class AddCodeToFuelSensorModels < ActiveRecord::Migration
  def change
    add_column :fuel_sensor_models, :code, :string

    FuelSensorModel.all.each do |model|
      model.code = model.title.downcase
      model.save
    end
    FuelSensorModel.create(:code => 'omnicomm', :title => 'Omnicomm') unless FuelSensorModel.find_by_code('omnicomm')
    FuelSensorModel.create(:code => 'native', :title => 'Native') unless FuelSensorModel.find_by_code('native')
  end
end
