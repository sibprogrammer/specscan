# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20121105125429) do

  create_table "fuel_sensor_models", :force => true do |t|
    t.string "title"
    t.string "description"
  end

  create_table "fuel_sensors", :force => true do |t|
    t.integer  "fuel_sensor_model_id"
    t.string   "code"
    t.string   "comments"
    t.integer  "vehicle_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "mobile_operators", :force => true do |t|
    t.string "title"
    t.string "code"
  end

  create_table "sim_cards", :force => true do |t|
    t.string   "phone"
    t.integer  "mobile_operator_id"
    t.decimal  "balance"
    t.string   "helper_password"
    t.string   "description"
    t.integer  "vehicle_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "last_check_error",   :default => false
  end

  create_table "tracker_models", :force => true do |t|
    t.string "code"
    t.string "title"
  end

  create_table "users", :force => true do |t|
    t.string   "email",                                 :default => "",    :null => false
    t.string   "encrypted_password",     :limit => 128, :default => "",    :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                         :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "login"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "role",                                  :default => 1
    t.string   "contact_name"
    t.string   "phone"
    t.string   "additional_info"
    t.string   "comment"
    t.boolean  "locked",                                :default => false
    t.integer  "owner_id",                              :default => 0
  end

  add_index "users", ["login"], :name => "index_users_on_login", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

  create_table "vehicle_types", :force => true do |t|
    t.string "code"
    t.string "title"
  end

  create_table "vehicles", :force => true do |t|
    t.string   "imei"
    t.string   "reg_number"
    t.string   "description"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.integer  "tracker_model_id",   :default => 0
    t.decimal  "fuel_norm"
    t.decimal  "fuel_tank"
    t.decimal  "fuel_tank2"
    t.text     "calibration_table"
    t.text     "calibration_table2"
    t.integer  "vehicle_type_id",    :default => 10
    t.integer  "fuel_calc_method",   :default => 1
    t.string   "comment"
    t.integer  "debt",               :default => 0
  end

  add_index "vehicles", ["user_id"], :name => "index_vehicles_on_user_id"

end
