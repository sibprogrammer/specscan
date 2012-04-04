class CreateTrackerModels < ActiveRecord::Migration
  def up
    create_table :tracker_models do |t|
      t.string :code
      t.string :title
    end

    TrackerModel.create(:code => 'galileo', :title => 'Galileo')
    TrackerModel.create(:code => 'tk103b', :title => 'TK-103B')
  end

  def down
    drop_table :tracker_models
  end
end
