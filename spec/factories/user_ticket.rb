FactoryBot.define do
  factory :user_ticket do
    email {'email@email.com'}
    link {nil}
    comment {'test test test'}
    subject {'meta-data error'}
    section_number {''}
    status {0}
  end
end


# create_table "user_tickets", force: :cascade do |t|
#   t.string   "name"
#   t.string   "email"
#   t.string   "link"
#   t.text     "comment"
#   t.integer  "status"
#   t.integer  "admin_id"
#   t.datetime "created_at",     null: false
#   t.datetime "updated_at",     null: false
#   t.string   "subject"
#   t.string   "section_number"
#   t.integer  "document_id"
# end