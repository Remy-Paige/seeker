require 'rails_helper'

RSpec.describe UserTicket, type: :model do

  subject do
    FactoryBot.create(:user_ticket)
  end

  it "has a valid factory" do
    user = create(:user)
    subject.user_id = user.id
    expect(subject).to be_valid
  end


end
