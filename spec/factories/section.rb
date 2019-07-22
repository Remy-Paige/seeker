FactoryGirl.define do
  factory :section do
    section_number '1.2'
    section_name 'New Section'
    content 'Lorem ipsum'
    association :document, factory: :document
  end
end


#   create_table "sections", force: :cascade do |t|
#     t.integer  "document_id"
#     t.text     "section_name"
#     t.text     "content"
#     t.datetime "created_at",     null: false
#     t.datetime "updated_at",     null: false
#     t.string   "section_number"
#     t.integer  "section_part"
#     t.integer  "page_number"
#   end