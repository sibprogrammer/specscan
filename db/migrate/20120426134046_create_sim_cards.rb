class CreateSimCards < ActiveRecord::Migration
  def change
    create_table :sim_cards do |t|
      t.string :phone
      t.integer :mobile_operator_id
      t.decimal :balance
      t.string :helper_password
      t.string :description
      t.integer :vehicle_id
      t.timestamps
    end
  end
end
