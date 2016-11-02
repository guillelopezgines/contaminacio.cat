# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20161102160414) do

  create_table "locations", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "code"
    t.string   "slug",                                              null: false
    t.string   "name"
    t.string   "city"
    t.decimal  "latitude",   precision: 8, scale: 6
    t.decimal  "longitude",  precision: 8, scale: 6
    t.boolean  "enabled",                            default: true
    t.datetime "created_at",                                        null: false
    t.datetime "updated_at",                                        null: false
    t.index ["code"], name: "index_locations_on_code", unique: true, using: :btree
  end

  create_table "logs", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.decimal  "value",         precision: 8, scale: 2
    t.integer  "pollutant_id",                          null: false
    t.integer  "location_id",                           null: false
    t.datetime "registered_at"
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.index ["location_id"], name: "index_logs_on_location_id", using: :btree
    t.index ["pollutant_id"], name: "index_logs_on_pollutant_id", using: :btree
  end

  create_table "pollutants", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name"
    t.string   "name_html"
    t.string   "short_name"
    t.string   "unit"
    t.string   "unit_html"
    t.string   "selector"
    t.decimal  "year_limit_spain",               precision: 8, scale: 2
    t.decimal  "year_limit_oms",                 precision: 8, scale: 2
    t.text     "description",      limit: 65535
    t.datetime "created_at",                                             null: false
    t.datetime "updated_at",                                             null: false
  end

end
