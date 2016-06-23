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

ActiveRecord::Schema.define(version: 20160622051604) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "documents", force: :cascade do |t|
    t.string   "url"
    t.string   "country"
    t.integer  "year"
    t.integer  "cycle"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "url_local"
  end

  create_table "languages", force: :cascade do |t|
    t.string   "country"
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "sections", force: :cascade do |t|
    t.integer  "document_id"
    t.text     "section_name"
    t.text     "content"
    t.integer  "language_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "sections", ["document_id"], name: "index_sections_on_document_id", using: :btree
  add_index "sections", ["language_id"], name: "index_sections_on_language_id", using: :btree

  create_table "user_tickets", force: :cascade do |t|
    t.string   "name"
    t.string   "email"
    t.string   "link"
    t.text     "comment"
    t.integer  "status"
    t.integer  "admin_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.integer  "role"
    t.string   "email"
    t.string   "name"
    t.string   "search_options"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

end
