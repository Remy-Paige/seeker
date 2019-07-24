

FactoryBot.define do

  sequence :section_number do |n|
    "1.#{n}"
  end
  sequence :section_name do |n|
    "Section #{n}"
  end


  factory :section do
    section_number {generate(:section_number)}
    section_name {generate(:section_name)}
    content {'Lorem ipsum'}
    section_part {0}
    page_number {0}
    association :document, factory: :document


    trait :full_content do
      section_number {'-'}
      section_name {'Full Content'}
      end

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