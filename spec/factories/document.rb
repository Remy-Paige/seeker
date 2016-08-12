FactoryGirl.define do
  factory :document do
    url 'http://www.coe.int/t/dg4/education/minlang/Report/EvaluationReports/UKECRML1_en.pdf'
    year 2003
    cycle 1
    document_type 1
    country

    trait :finished_parsing do
      parsing_finished true
    end

    trait :parsing do
      parsing_finished false
    end
  end
end
