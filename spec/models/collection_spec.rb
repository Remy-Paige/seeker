require 'rails_helper'

RSpec.describe Collection, type: :model do

  it "has a valid factory" do
    expect(FactoryBot.create(:collection)).to be_valid
    # FactoryBot.create(:collection).should be_valid
  end

  it "is invalid without a name" do
    # Factory() builds the model and saves it
    # Factory.build() instantiates a new model, but doesn’t save it
    # use the Contact factory’s defaults for every attribute except :firstname

    expect(FactoryBot.build(:collection, name: nil)).not_to be_valid
  end

  it "belongs to a user or an admin" do
    # expect(FactoryBot.build(:collection).user).to be_valid
    pending
  end


  describe 'save_section(params, user)' do

    it "returns 'nil collection' if the collection doesnt exist" do

    end

    it "adds a collection_document entry with the section number and returns 'first submit' if one does not already exist" do

    end

    it "returns 'second submit' if a matching record already exists" do

    end
  #   TODO: fix double submit javascript problem

  end

  describe 'remove_section(params)' do

    it "destroys the matching relation" do

    end

    it "does nothing if no relation matches" do

    end

  end


end
