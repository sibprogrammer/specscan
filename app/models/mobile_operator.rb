class MobileOperator < ActiveRecord::Base

  validates :title, :uniqueness => true, :presence => true
  validates :code, :uniqueness => true, :presence => true, :format => { :with => /\A[\da-z]+\z/ }

end
