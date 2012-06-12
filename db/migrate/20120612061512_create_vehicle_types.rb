class CreateVehicleTypes < ActiveRecord::Migration
  def change
    create_table :vehicle_types do |t|
      t.string :code
      t.string :title
    end
    
    VehicleType.create(:code => 'car', :title => 'легковая')
    VehicleType.create(:code => 'truck', :title => 'грузовик')
    VehicleType.create(:code => 'tipper', :title => 'самосвал')
    VehicleType.create(:code => 'tower', :title => 'автовышка')
    VehicleType.create(:code => 'mixer', :title => 'миксер')
    VehicleType.create(:code => 'excavator', :title => 'экскаватор')
    VehicleType.create(:code => 'bus', :title => 'автобус')
    VehicleType.create(:code => 'loader', :title => 'погрузчик')
    VehicleType.create(:code => 'crane', :title => 'кран')
    VehicleType.create(:code => 'other', :title => 'прочее')
  end
end
