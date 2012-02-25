class AddAdditionalFieldsToUsers < ActiveRecord::Migration
  def change
    change_table :users do |t|
      t.string :contact_name
      t.string :phone
      t.string :additional_info
      t.string :comment
    end
  end
end
