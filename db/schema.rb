# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2025_04_10_193449) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "carried_over_messages", force: :cascade do |t|
    t.integer "job_id", null: false
    t.datetime "job_created_at", null: false
    t.string "bioguide_id", null: false
    t.string "campaign_tag"
    t.text "fields", null: false
    t.string "tags"
    t.string "last_status"
    t.string "last_screenshot"
    t.datetime "last_attempted_at", default: "1970-01-01 00:00:00"
    t.integer "attempts", default: 0
    t.boolean "complete", default: false
  end

  create_table "defunct_congress_forms", force: :cascade do |t|
    t.string "bioguide_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "reason"
    t.index ["bioguide_id"], name: "index_defunct_congress_forms_on_bioguide_id", unique: true
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer "priority", default: 0, null: false
    t.integer "attempts", default: 0, null: false
    t.text "handler", null: false
    t.text "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by"
    t.string "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "fills", force: :cascade do |t|
    t.string "bioguide_id", null: false
    t.string "campaign_tag"
    t.string "status", null: false
    t.string "screenshot"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["bioguide_id", "status"], name: "index_fills_on_bioguide_id_and_status"
    t.index ["bioguide_id"], name: "index_fills_on_bioguide_id"
    t.index ["campaign_tag"], name: "index_fills_on_campaign_tag"
  end

end
