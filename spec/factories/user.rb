FactoryGirl.define do
  sequence :email do |n|
    "user#{n}@seeker.com"
  end
end

FactoryGirl.define do
  factory :user do
    email
    password 'password'
    password_confirmation 'password'
  end
end
