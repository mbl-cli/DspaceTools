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

ActiveRecord::Schema.define(version: 20130225174903) do

  create_table "api_keys", force: true do |t|
    t.integer  "eperson_id"
    t.string   "app_name"
    t.string   "public_key"
    t.string   "private_key"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "api_keys", ["eperson_id"], name: "idx_api_keys_1", using: :btree
  add_index "api_keys", ["public_key"], name: "idx_api_keys_2", unique: true, using: :btree

  create_table "bitstream", primary_key: "bitstream_id", force: true do |t|
    t.integer "bistream_format_id",                    null: false
    t.string  "name",                                  null: false
    t.integer "size_bytes",                            null: false
    t.string  "checksum",                              null: false
    t.string  "checksum_algorithm",                    null: false
    t.string  "description"
    t.string  "user_format_description"
    t.string  "source"
    t.integer "internal_id",                           null: false
    t.string  "deleted",                 default: "f", null: false
    t.integer "store_number",                          null: false
    t.integer "sequence_id",                           null: false
  end

  create_table "collection", primary_key: "collection_id", force: true do |t|
    t.string  "name"
    t.string  "short_description"
    t.string  "introductory_text"
    t.integer "logo_bitstream_id"
    t.integer "template_item_id"
    t.string  "provenance_description"
    t.string  "license"
    t.string  "copyright_text"
    t.string  "side_bar_text"
    t.string  "sidebar_text"
    t.string  "workflow_step_1"
    t.string  "workflow_step_2"
    t.integer "submitter"
    t.integer "admin"
  end

  create_table "community", primary_key: "community_id", force: true do |t|
    t.string  "name"
    t.string  "short_description"
    t.string  "introductory_text"
    t.integer "logo_bitstream_id"
    t.string  "copyright_text"
    t.string  "side_bar_text"
    t.integer "admin"
  end

  create_table "eperson", primary_key: "eperson_id", force: true do |t|
    t.string   "email"
    t.string   "password"
    t.string   "firstname"
    t.string   "lastname"
    t.integer  "can_log_in",          limit: 1, default: 1
    t.integer  "require_certificate", limit: 1, default: 0
    t.integer  "self_registered",     limit: 1, default: 1
    t.datetime "last_active"
    t.integer  "sub_frequency"
    t.string   "phone"
    t.string   "language"
  end

  add_index "eperson", ["email"], name: "idx_api_keys_2", unique: true, using: :btree

  create_table "epersongroup", primary_key: "eperson_group_id", force: true do |t|
    t.string "name"
  end

  create_table "epersongroup2eperson", force: true do |t|
    t.integer "eperson_group_id", null: false
    t.integer "eperson_id",       null: false
  end

  create_table "handle", primary_key: "handle_id", force: true do |t|
    t.string  "handle"
    t.integer "resource_type_id", null: false
    t.integer "resource_id",      null: false
  end

  add_index "handle", ["handle"], name: "index_handle_on_handle", unique: true, using: :btree

  create_table "item", primary_key: "item_id", force: true do |t|
    t.string   "submitter_id"
    t.string   "in_archive",        default: "t", null: false
    t.string   "withdrawn",         default: "f", null: false
    t.datetime "last_modified"
    t.integer  "owning_collection",               null: false
  end

  create_table "resourcepolicy", primary_key: "policy_id", force: true do |t|
    t.integer  "resource_type_id", null: false
    t.integer  "resource_id",      null: false
    t.integer  "action_id",        null: false
    t.integer  "eperson_id"
    t.integer  "epersongroup_id"
    t.datetime "start_date"
    t.datetime "end_date"
  end

  create_table "sessions", force: true do |t|
    t.text "session_id"
    t.text "data"
  end

  add_index "sessions", ["session_id"], name: "idx_sessions_1", length: {"session_id"=>100}, using: :btree

end
