class CreatePlans < ActiveRecord::Migration
  def change
    create_table :plans do |t|
      t.string :name
      t.string :description
      t.decimal :price
      t.integer :billing_period

      t.timestamps
    end
  end
end
