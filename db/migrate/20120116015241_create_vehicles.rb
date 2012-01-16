class CreateVehicles < ActiveRecord::Migration

  def change
    create_table :vehicles do |t|
      t.string :imei
      t.string :reg_number
      t.string :description
      t.references :user
      t.timestamps
    end

    add_index :vehicles, :user_id
  end

end
