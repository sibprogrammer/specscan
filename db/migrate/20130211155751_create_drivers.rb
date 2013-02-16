class CreateDrivers < ActiveRecord::Migration
  def change
    create_table :drivers do |t|
      t.string :name
      t.date :birthday
      t.string :license_number
      t.date :license_start
      t.date :license_end
      t.string :categories
      t.string :additional_info
      t.integer :owner_id
      t.integer :vehicle_id, :default => 0
      t.timestamps
    end
  end
end
