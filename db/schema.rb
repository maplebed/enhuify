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

ActiveRecord::Schema.define(version: 20180418034420) do

  create_table "bulbs", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "hue"
    t.integer "saturation"
    t.integer "brightness"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "request_id"
  end

  create_table "changelogs", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "remote_ip"
    t.string "request_id"
    t.datetime "created_at", precision: 3, null: false
    t.datetime "updated_at", precision: 3, null: false
    t.string "action"
    t.integer "bulb_id"
    t.string "hue"
    t.string "saturation"
    t.string "brightness"
    t.boolean "succeeded"
    t.boolean "processed"
    t.string "color"
  end

end
