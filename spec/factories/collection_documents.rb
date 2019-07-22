FactoryBot.define do
  factory :collection_document do
    # before_destroy {documents.clear}
    #

    association :document, factory: :document
    association :collection, factory: :collection
    section_number {'1.2'}

  end
end


#   create_table "collection_documents", force: :cascade do |t|
#     t.integer  "collection_id"
#     t.integer  "document_id"
#     t.string   "section_number"
#     t.datetime "created_at",     null: false
#     t.datetime "updated_at",     null: false
#   end