class AddOwnerToUsers < ActiveRecord::Migration
  def change
    add_column :users, :owner_id, :integer, :default => 0
  end
end
