class Admin::SearchController < Admin::Base

  def results
    @results = find_items(params[:term])
    @results = @results[0,9]
    render :layout => false
  end

  private

    def find_items(term)
      items = []

      if can?(:manage, Vehicle) or (current_user.owner and current_user.owner.admin?)
        conditions = ['imei LIKE ? OR name LIKE ? OR reg_number LIKE ?', "%#{term}%", "%#{term}%", "%#{term}%"]
        vehicles = Vehicle.find(:all, :limit => 10, :conditions => conditions)
      else
        user = current_user.user? ? current_user.owner : current_user
        conditions = ['name LIKE ? OR reg_number LIKE ?', "%#{term}%", "%#{term}%"]
        vehicles = user.vehicles.find(:all, :limit => 10, :conditions => conditions)
      end

      vehicles.each do |vehicle|
        items << {
          :object_type => t('admin.search.results.object_type.vehicle'),
          :title => vehicle.title,
          :link => day_report_admin_vehicle_path(vehicle),
        }
      end

      return items if items.length > 10 or !current_user.admin?

      conditions = ['login LIKE ? OR name LIKE ? OR email LIKE ?', "%#{term}%", "%#{term}%", "%#{term}%"]
      clients = User.clients.find(:all, :limit => 10, :conditions => conditions)

      clients.each do |client|
        items << {
          :object_type => t('admin.search.results.object_type.client'),
          :title => "#{client.name} (#{client.login})",
          :link => admin_user_path(client),
        }
      end

      return items if items.length > 10

      conditions = ['phone LIKE ? or identity LIKE ?', "%#{term}%", "%#{term}%"]
      sim_cards = SimCard.find(:all, :limit => 10, :conditions => conditions)

      sim_cards.each do |sim_card|
        items << {
          :object_type => t('admin.search.results.object_type.sim_card'),
          :title => sim_card.phone,
          :link => admin_sim_card_path(sim_card), 
        }
      end

      return items if items.length > 10

      conditions = ['code LIKE ?', "%#{term}%"]
      fuel_sensors = FuelSensor.find(:all, :limit => 10, :conditions => conditions)

      fuel_sensors.each do |fuel_sensor|
        items << {
          :object_type => t('admin.search.results.object_type.fuel_sensor'),
          :title => "#{fuel_sensor.code} (#{fuel_sensor.fuel_sensor_model.title})",
          :link => admin_fuel_sensor_path(fuel_sensor),
        }
      end

      items
    end

end
