class VehicleType < ActiveRecord::Base

  validates :code, :presence => true, :uniqueness => true, :format => { :with => /\A[a-z]+\z/ }
  validates :title, :presence => true, :uniqueness => true

end
