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

ActiveRecord::Schema.define(version: 2019_05_02_211408) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "parsing_stats_parse_attempts", force: :cascade do |t|
    t.string "url", limit: 512, null: false
    t.integer "url_type", null: false
    t.boolean "detected", default: false, null: false
    t.text "error"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "website_id", null: false
    t.index ["website_id"], name: "index_parsing_stats_parse_attempts_on_website_id"
  end

  create_table "parsing_stats_providers", force: :cascade do |t|
    t.string "name", limit: 32
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_parsing_stats_providers_on_name", unique: true
  end

  create_table "parsing_stats_websites", force: :cascade do |t|
    t.string "domain", null: false
    t.integer "success_count", default: 0, null: false
    t.integer "failure_count", default: 0, null: false
    t.bigint "provider_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["domain"], name: "index_parsing_stats_websites_on_domain", unique: true
    t.index ["provider_id"], name: "index_parsing_stats_websites_on_provider_id"
  end

  add_foreign_key "parsing_stats_parse_attempts", "parsing_stats_websites", column: "website_id", on_delete: :cascade
  add_foreign_key "parsing_stats_websites", "parsing_stats_providers", column: "provider_id", on_delete: :cascade
end
