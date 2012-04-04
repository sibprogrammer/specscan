class TrackerModel < ActiveRecord::Base

  validates :code, :uniqueness => true, :presence => true
  validates :title, :presence => true

  has_many :vehicles

end
