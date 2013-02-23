collection @vehicles
attributes :id, :name, :reg_number, :vehicle_type_id
node(:is_moving) { |vehicle| vehicle.moving? }
