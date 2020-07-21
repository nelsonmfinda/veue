# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_07_20_195019) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "admins", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["confirmation_token"], name: "index_admins_on_confirmation_token", unique: true
    t.index ["email"], name: "index_admins_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admins_on_reset_password_token", unique: true
    t.index ["unlock_token"], name: "index_admins_on_unlock_token", unique: true
  end

  create_table "mux_assets", force: :cascade do |t|
    t.string "state"
    t.string "mux_id"
    t.string "playback_id"
    t.bigint "user_id", null: false
    t.bigint "video_id", null: false
    t.string "mux_status"
    t.float "duration"
    t.string "max_stored_resolution"
    t.float "max_stored_frame_rate"
    t.string "aspect_ratio"
    t.boolean "per_title_encode"
    t.boolean "is_live"
    t.datetime "deleted_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["mux_id"], name: "index_mux_assets_on_mux_id"
    t.index ["user_id"], name: "index_mux_assets_on_user_id"
    t.index ["video_id"], name: "index_mux_assets_on_video_id"
  end

  create_table "mux_live_streams", force: :cascade do |t|
    t.bigint "user_id"
    t.string "state"
    t.string "mux_id"
    t.string "stream_key"
    t.string "playback_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["mux_id"], name: "index_mux_live_streams_on_mux_id"
    t.index ["user_id", "state"], name: "index_mux_live_streams_on_user_id_and_state"
  end

  create_table "mux_webhooks", force: :cascade do |t|
    t.string "mux_target_type"
    t.bigint "mux_target_id"
    t.string "type"
    t.string "event"
    t.string "webhook_id"
    t.datetime "event_at"
    t.string "environment"
    t.text "json"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["mux_target_type", "mux_target_id"], name: "index_mux_webhooks_on_mux_target_type_and_mux_target_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "username"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.bigint "mux_live_stream_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["mux_live_stream_id"], name: "index_users_on_mux_live_stream_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  create_table "videos", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "slug"
    t.string "title"
    t.string "playback_url"
    t.string "state"
    t.bigint "mux_live_stream_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["mux_live_stream_id"], name: "index_videos_on_mux_live_stream_id"
    t.index ["state"], name: "index_videos_on_state"
    t.index ["user_id"], name: "index_videos_on_user_id"
  end

  add_foreign_key "mux_assets", "users"
  add_foreign_key "mux_assets", "videos"
  add_foreign_key "videos", "users"
end
