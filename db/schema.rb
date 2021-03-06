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

ActiveRecord::Schema.define(version: 20160517130554) do

  create_table "albums", force: :cascade do |t|
    t.string   "original_avatar_url", null: false
    t.integer  "user_id"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
    t.boolean  "image_processing"
    t.string   "avatar"
  end

  add_index "albums", ["user_id"], name: "index_albums_on_user_id"

  create_table "flags", force: :cascade do |t|
    t.integer  "flaged_id"
    t.integer  "flager_id"
    t.text     "flag_message"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "flags", ["flaged_id", "flager_id"], name: "index_flags_on_flaged_id_and_flager_id", unique: true
  add_index "flags", ["flaged_id"], name: "index_flags_on_flaged_id"
  add_index "flags", ["flager_id"], name: "index_flags_on_flager_id"

  create_table "messages", force: :cascade do |t|
    t.integer  "sender_id"
    t.integer  "reply_post_id"
    t.text     "content"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "messages", ["reply_post_id"], name: "index_messages_on_reply_post_id"
  add_index "messages", ["sender_id", "reply_post_id"], name: "index_messages_on_sender_id_and_reply_post_id", unique: true
  add_index "messages", ["sender_id"], name: "index_messages_on_sender_id"

  create_table "photos", force: :cascade do |t|
    t.string   "image"
    t.integer  "user_id"
    t.string   "original_image_url", null: false
    t.boolean  "image_processing"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
  end

  add_index "photos", ["user_id"], name: "index_photos_on_user_id"

  create_table "posts", force: :cascade do |t|
    t.string   "title",                        null: false
    t.string   "city"
    t.string   "postal_code"
    t.date     "meeting_date"
    t.text     "description",                  null: false
    t.integer  "user_id"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.string   "gender"
    t.boolean  "published",    default: false
    t.string   "slug"
    t.float    "lat"
    t.float    "lon"
    t.boolean  "flaged",       default: false
    t.integer  "flag_number",  default: 0
  end

  add_index "posts", ["created_at"], name: "index_posts_on_created_at"
  add_index "posts", ["flag_number"], name: "index_posts_on_flag_number"
  add_index "posts", ["gender"], name: "index_posts_on_gender"
  add_index "posts", ["slug"], name: "index_posts_on_slug", unique: true
  add_index "posts", ["user_id"], name: "index_posts_on_user_id"

  create_table "relationships", force: :cascade do |t|
    t.integer  "follower_id"
    t.integer  "followed_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "relationships", ["followed_id"], name: "index_relationships_on_followed_id"
  add_index "relationships", ["follower_id", "followed_id"], name: "index_relationships_on_follower_id_and_followed_id", unique: true
  add_index "relationships", ["follower_id"], name: "index_relationships_on_follower_id"

  create_table "reports", force: :cascade do |t|
    t.integer  "reported_id"
    t.integer  "reporter_id"
    t.text     "report_message"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  add_index "reports", ["reported_id", "reporter_id"], name: "index_reports_on_reported_id_and_reporter_id", unique: true
  add_index "reports", ["reported_id"], name: "index_reports_on_reported_id"
  add_index "reports", ["reporter_id"], name: "index_reports_on_reporter_id"

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "",    null: false
    t.string   "encrypted_password",     default: "",    null: false
    t.string   "username",               default: ""
    t.string   "gender",                 default: "M",   null: false
    t.date     "date_of_birth"
    t.text     "description",            default: ""
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.integer  "failed_attempts",        default: 0,     null: false
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.boolean  "admin",                  default: false
    t.string   "uid"
    t.integer  "cached_failed_attempts", default: 0
    t.boolean  "reported",               default: false
    t.boolean  "blocked",                default: false
    t.boolean  "superadmin",             default: false
    t.integer  "report_number",          default: 0
  end

  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
  add_index "users", ["created_at"], name: "index_users_on_created_at"
  add_index "users", ["date_of_birth"], name: "index_users_on_date_of_birth"
  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["gender"], name: "index_users_on_gender"
  add_index "users", ["report_number"], name: "index_users_on_report_number"
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  add_index "users", ["uid"], name: "index_users_on_uid", unique: true
  add_index "users", ["unlock_token"], name: "index_users_on_unlock_token", unique: true

end
