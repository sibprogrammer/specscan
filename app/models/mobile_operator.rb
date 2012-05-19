class MobileOperator < ActiveRecord::Base

  validates :title, :uniqueness => true, :presence => true
  validates :code, :uniqueness => true, :presence => true

end
