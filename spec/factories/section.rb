FactoryGirl.define do
  factory :section do
    section_number '1.2'
    section_name 'New Section'
    content 'Lorem ipsum'
    association :document, factory: :document
  end
end
