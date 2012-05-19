class CreateMobileOperators < ActiveRecord::Migration
  def change
    create_table :mobile_operators do |t|
      t.string :title
      t.string :code
    end

    MobileOperator.create(:title => 'МТС', :code => 'mts')
    MobileOperator.create(:title => 'Билайн', :code => 'beeline')
    MobileOperator.create(:title => 'МегаФон', :code => 'megafon')
    MobileOperator.create(:title => 'ТЕЛЕ-2', :code => 'tele2')
  end
end
