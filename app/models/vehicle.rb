class Vehicle < ActiveRecord::Base

  validates :imei, :presence => true, :uniqueness => true

  belongs_to :user

end
