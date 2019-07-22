FactoryBot.define do
  factory :language_section do

    association :language, factory: :language
    association :section, factory: :section
    strength {1}


  end
end


#   create_table "language_sections", force: :cascade do |t|
#     t.integer  "section_id"
#     t.integer  "language_id"
#     t.integer  "strength"
#     t.datetime "created_at",  null: false
#     t.datetime "updated_at",  null: false
#   end