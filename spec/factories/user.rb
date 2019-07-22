FactoryBot.define do
  sequence :email do |n|
    "user#{n}@seeker.com"
  end
end

FactoryBot.define do
  factory :user do
    email
    name  {'joseph smith'}
    password {'password'}
    password_confirmation {'password'}
    admin {true}


    trait :not_admin do
      admin {false}
    end

  end
end


