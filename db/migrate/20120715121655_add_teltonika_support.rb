class AddTeltonikaSupport < ActiveRecord::Migration
  def up
    TrackerModel.create(:code => 'teltonika', :title => 'Teltonika')
  end

  def down
  end
end
