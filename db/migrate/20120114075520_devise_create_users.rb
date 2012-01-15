class DeviseCreateUsers < ActiveRecord::Migration

  def change
    create_table(:users) do |t|
      t.database_authenticatable :null => false
      t.recoverable
      t.rememberable
      t.trackable
      t.string :login
      t.string :name
      t.timestamps
    end

    add_index :users, :login, :unique => true
    add_index :users, :reset_password_token, :unique => true
  end

end
