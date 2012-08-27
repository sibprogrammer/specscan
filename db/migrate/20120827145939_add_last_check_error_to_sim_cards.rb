class AddLastCheckErrorToSimCards < ActiveRecord::Migration
  def change
    add_column :sim_cards, :last_check_error, :boolean, :default => false
  end
end
