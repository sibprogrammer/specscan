class MobileOperator < ActiveRecord::Base

  validates :title, :uniqueness => true, :presence => true

end
