FactoryBot.define do
  factory :admin do
    email
    password {'password'}
    password_confirmation {'password'}

    #ignore red wiggily line
    after(:create) do |admin|
      create(:collection, admin: admin, user: nil)
      create(:user_ticket, admin: admin, status: 1)
    end
  end
end
