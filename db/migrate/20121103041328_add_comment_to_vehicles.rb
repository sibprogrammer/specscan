class AddCommentToVehicles < ActiveRecord::Migration
  def change
    add_column :vehicles, :comment, :string
  end
end
