class CreateMobileOperators < ActiveRecord::Migration
  def change
    create_table :mobile_operators do |t|
      t.string :title
    end

    MobileOperator.create(:title => 'МТС')
    MobileOperator.create(:title => 'Билайн')
    MobileOperator.create(:title => 'МегаФон')
    MobileOperator.create(:title => 'ТЕЛЕ-2')
  end
end
