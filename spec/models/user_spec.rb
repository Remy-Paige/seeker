require 'rails_helper'

RSpec.describe User, type: :model do

  subject do
    FactoryBot.create(:user)
  end

  it "has a valid factory" do
    expect(subject).to be_valid
  end

  describe '#convert_to_admin' do

  end

end



