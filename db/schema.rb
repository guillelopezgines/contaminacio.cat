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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20191128142459) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "historics", force: :cascade do |t|
    t.integer "year"
    t.integer "location_id",                          null: false
    t.integer "pollutant_id",                         null: false
    t.decimal "value",        precision: 8, scale: 2
    t.index ["location_id"], name: "index_historics_on_location_id", using: :btree
    t.index ["pollutant_id"], name: "index_historics_on_pollutant_id", using: :btree
    t.index ["year"], name: "index_historics_on_year", using: :btree
  end

  create_table "locations", force: :cascade do |t|
    t.string   "code"
    t.string   "name"
    t.string   "city"
    t.decimal  "latitude",            precision: 8, scale: 6
    t.decimal  "longitude",           precision: 8, scale: 6
    t.boolean  "enabled",                                     default: true
    t.datetime "created_at",                                                      null: false
    t.datetime "updated_at",                                                      null: false
    t.string   "slug",                                                            null: false
    t.string   "address"
    t.string   "zipcode"
    t.string   "district"
    t.string   "category",                                    default: "STATION", null: false
    t.boolean  "is_kindergarden",                             default: false,     null: false
    t.boolean  "is_primary_school",                           default: false,     null: false
    t.boolean  "is_secondary_school",                         default: false,     null: false
    t.boolean  "is_high_school",                              default: false,     null: false
    t.boolean  "is_special_school",                           default: false,     null: false
    t.string   "district_handle"
    t.boolean  "adhered",                                     default: false,     null: false
    t.index ["category"], name: "index_locations_on_category", using: :btree
    t.index ["code"], name: "index_locations_on_code", unique: true, using: :btree
    t.index ["district_handle"], name: "index_locations_on_district_handle", using: :btree
  end

  create_table "logs", force: :cascade do |t|
    t.decimal  "value",            precision: 8, scale: 2
    t.datetime "registered_at"
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
    t.integer  "location_id",                              null: false
    t.integer  "pollutant_id",                             null: false
    t.decimal  "annual_sum",       precision: 8, scale: 2
    t.integer  "annual_registers"
    t.index ["location_id"], name: "index_logs_on_location_id", using: :btree
    t.index ["pollutant_id"], name: "index_logs_on_pollutant_id", using: :btree
  end

  create_table "pollutants", force: :cascade do |t|
    t.string   "name"
    t.string   "name_html"
    t.string   "short_name"
    t.string   "unit"
    t.string   "unit_html"
    t.string   "selector"
    t.decimal  "year_limit_spain", precision: 8, scale: 2
    t.decimal  "year_limit_oms",   precision: 8, scale: 2
    t.text     "description"
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
  end

end
