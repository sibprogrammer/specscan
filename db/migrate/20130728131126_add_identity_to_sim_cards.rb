class AddIdentityToSimCards < ActiveRecord::Migration
  def change
    add_column :sim_cards, :identity, :string
  end
end
