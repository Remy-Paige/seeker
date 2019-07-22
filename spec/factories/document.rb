FactoryBot.define do
  factory :document do
    url {'http://www.coe.int/t/dg4/education/minlang/Report/EvaluationReports/UKECRML1_en.pdf'}
    year {2003}
    cycle {1}
    document_type {1}
    association :country, factory: :country

    trait :finished_parsing do
      status {2}
    end

    trait :parsing do
      status {0}
    end

    trait :failed do
      status {1}
    end

  end
end


# create_table "documents", force: :cascade do |t|
#   t.string   "url"
#   t.integer  "country_id"
#   t.integer  "year"
#   t.integer  "cycle"
#   t.datetime "created_at",                       null: false
#   t.datetime "updated_at",                       null: false
#   t.string   "url_local"
#   t.boolean  "parsing_finished", default: false
#   t.integer  "document_type"
#   t.integer  "status"
# end