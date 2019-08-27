FactoryBot.define do
  sequence :email do |n|
    "user#{n}@seeker.com"
  end
end

FactoryBot.define do
  factory :user do
    email
    password {'password'}
    password_confirmation {'password'}
    #ignore red wiggily line
    after(:create) do |user|
      create(:collection, user: user, admin: nil)
      create(:user_ticket, user: user, status: 0)
      admin = create(:admin)
      create(:user_ticket, user: user, admin: admin, status: 1)
    end
  end
end


