namespace :sim_balance do

  desc "Update SIM-cards balances"
  task :update => :environment do
    SimCard.all.each do |sim_card|
      next if sim_card.helper_password.blank?
      sim_card.update_balance
    end
  end

end
