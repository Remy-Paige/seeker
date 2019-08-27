require 'rails_helper'

RSpec.describe User, type: :model do

  subject do
    FactoryBot.create(:user)
  end

  it "has a valid factory" do
    expect(subject).to be_valid
  end

  describe '#convert_to_admin' do

    it "destroys the user and creates an identical admin" do
      user = FactoryBot.create(:user)

      user2 = user
      admin = user.convert_to_admin

      expect(admin.attributes).to eq(user2.attributes)
    end

    # after create doesnt seem to work
    it "transfers collections from the user to the admin" do
      user = FactoryBot.create(:user)
      collection = FactoryBot.create(:collection)

      user.collections << collection
      puts(user.collections)
      collections = user.collections
      admin = user.convert_to_admin

      puts(collections.length)
      collections.each_with_index do |collection, index|
        puts(index)
        expect(collection.user_id).to eq(nil)
        expect(collection.admin_id).to eq(admin.id)
      end
    end

    it "changes any unmanaged tickets to open with a nil user_id, associated to self" do
      user = FactoryBot.create(:user)

      tickets = user.user_tickets

      unmanaged = nil
      tickets.each do |ticket|
        if ticket.status == 0
          unmanaged = ticket
        end
      end
      admin = user.convert_to_admin

      expect(unmanaged.user_id).to eq(nil)
      expect(unmanaged.admin_id).to eq(admin.id)
      expect(unmanaged.status).to eq(1)
    end

    it "changes any open tickets to have a nil user_id" do
      user = FactoryBot.create(:user)

      tickets = user.user_tickets

      open = nil
      tickets.each_with_index do |ticket, index|
        if ticket.status == 1
          open = index
        end
      end

      admin = user.convert_to_admin

      tickets.each do |ticket|
      end

    end
  end

end



