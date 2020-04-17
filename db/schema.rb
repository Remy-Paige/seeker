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

ActiveRecord::Schema.define(version: 20200226210819) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "collection_documents", force: :cascade do |t|
    t.integer  "collection_id"
    t.integer  "document_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.string   "section_uid"
  end

  add_index "collection_documents", ["collection_id"], name: "index_collection_documents_on_collection_id", using: :btree
  add_index "collection_documents", ["document_id"], name: "index_collection_documents_on_document_id", using: :btree

  create_table "collections", force: :cascade do |t|
    t.integer  "user_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.string   "name"
    t.string   "description"
  end

  add_index "collections", ["user_id"], name: "index_collections_on_user_id", using: :btree

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
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.string   "url_local"
    t.integer  "document_type"
    t.integer  "status"
  end

  add_index "documents", ["country_id"], name: "index_documents_on_country_id", using: :btree

  create_table "language_sections", force: :cascade do |t|
    t.integer  "section_id"
    t.integer  "language_id"
    t.integer  "strength"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "language_sections", ["language_id"], name: "index_language_sections_on_language_id", using: :btree
  add_index "language_sections", ["section_id"], name: "index_language_sections_on_section_id", using: :btree

  create_table "languages", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "queries", force: :cascade do |t|
    t.integer  "collection_id"
    t.text     "query"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.text     "feedback"
  end

  add_index "queries", ["collection_id"], name: "index_queries_on_collection_id", using: :btree

  create_table "sections", force: :cascade do |t|
    t.integer  "document_id"
    t.text     "section_name"
    t.text     "content"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.string   "section_number"
    t.integer  "section_part"
    t.integer  "page_number"
    t.integer  "chapter"
    t.string   "article_paragraph"
    t.string   "section_uid"
  end

  add_index "sections", ["document_id"], name: "index_sections_on_document_id", using: :btree

  create_table "user_tickets", force: :cascade do |t|
    t.string   "email"
    t.string   "link"
    t.text     "comment"
    t.integer  "status"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.string   "subject"
    t.integer  "document_id"
    t.integer  "user_id"
    t.string   "section_uid"
  end

  add_index "user_tickets", ["document_id"], name: "index_user_tickets_on_document_id", using: :btree
  add_index "user_tickets", ["user_id"], name: "index_user_tickets_on_user_id", using: :btree

  create_table "user_user_tickets", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "user_ticket_id"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.boolean  "manages_owns"
  end

  add_index "user_user_tickets", ["user_id"], name: "index_user_user_tickets_on_user_id", using: :btree
  add_index "user_user_tickets", ["user_ticket_id"], name: "index_user_user_tickets_on_user_ticket_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.boolean  "admin"
    t.string   "name"
    t.string   "recent_url"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  add_foreign_key "user_tickets", "users"
end
