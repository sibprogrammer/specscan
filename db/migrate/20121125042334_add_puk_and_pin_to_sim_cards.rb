class AddPukAndPinToSimCards < ActiveRecord::Migration
  def change
    add_column :sim_cards, :pin_code, :string
    add_column :sim_cards, :puk_code, :string
  end
end
