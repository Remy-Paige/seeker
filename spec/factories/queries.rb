FactoryGirl.define do
  factory :query do

    association :collection, factory: :collection
  #   TODO: wtf

  end
end


#   create_table "queries", force: :cascade do |t|
#     t.integer  "collection_id"
#     t.text     "query"
#     t.datetime "created_at",    null: false
#     t.datetime "updated_at",    null: false
#   end