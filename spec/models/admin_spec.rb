require 'rails_helper'

RSpec.describe Admin, type: :model do

  subject do
    FactoryBot.create(:admin)
  end

  it "has a valid factory" do
    expect(subject).to be_valid
  end

  describe '#convert_to_user' do

    it "destroys the admin and creates an identical user" do
      admin = FactoryBot.create(:admin)

      admin2 = admin
      user = admin.convert_to_user

      expect(user.attributes).to eq(admin2.attributes)

    end

    it "transfers collections from the admin to the user" do
      admin = FactoryBot.create(:admin)

      collections = admin.collections
      user = admin.convert_to_user

      collections.each do |collection|
        expect(collection.user_id).to eq(user.id)
        expect(collection.admin_id).to eq(nil)
      end


    end

    it "removes the reference to admin from any tickets and updates their status to unmanaged" do
      admin = FactoryBot.create(:admin)

      tickets = admin.user_tickets
      user = admin.convert_to_user

      tickets.each do |ticket|
        expect(ticket.admin_id).to eq(nil)
        expect(ticket.status).to eq(0)
      end
    end

  end
end
