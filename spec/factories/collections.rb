FactoryGirl.define do
  factory :collection do
    name 'my collection'
    association :user, factory: :user
  end


end
