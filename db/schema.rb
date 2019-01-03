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

ActiveRecord::Schema.define(version: 20190103165302) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "countries", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "countries_languages", id: false, force: :cascade do |t|
    t.integer "country_id"
    t.integer "language_id"
  end

  add_index "countries_languages", ["country_id"], name: "index_countries_languages_on_country_id", using: :btree
  add_index "countries_languages", ["language_id"], name: "index_countries_languages_on_language_id", using: :btree

  create_table "documents", force: :cascade do |t|
    t.string   "url"
    t.integer  "country_id"
    t.integer  "year"
    t.integer  "cycle"
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.string   "url_local"
    t.boolean  "parsing_finished", default: false
    t.integer  "document_type"
  end

  add_index "documents", ["country_id"], name: "index_documents_on_country_id", using: :btree

  create_table "languages", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "sections", force: :cascade do |t|
    t.integer  "document_id"
    t.text     "section_name"
    t.text     "content"
    t.integer  "language_id"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.string   "section_number"
    t.integer  "section_part"
    t.integer  "page_number"
  end

  add_index "sections", ["document_id"], name: "index_sections_on_document_id", using: :btree
  add_index "sections", ["language_id"], name: "index_sections_on_language_id", using: :btree

  create_table "ticket_relations", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "user_ticket_id"
    t.boolean  "manages"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  add_index "ticket_relations", ["user_id"], name: "index_ticket_relations_on_user_id", using: :btree
  add_index "ticket_relations", ["user_ticket_id"], name: "index_ticket_relations_on_user_ticket_id", using: :btree

  create_table "user_tickets", force: :cascade do |t|
    t.string   "name"
    t.string   "email"
    t.string   "link"
    t.text     "comment"
    t.integer  "status"
    t.integer  "admin_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "subject"
  end

  create_table "users", force: :cascade do |t|
    t.integer  "role"
    t.string   "email",                  default: "",    null: false
    t.string   "name"
    t.string   "search_options"
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.string   "encrypted_password",     default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.boolean  "admin",                  default: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
