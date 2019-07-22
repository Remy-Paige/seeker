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

  it "belongs to a user" do
    expect(FactoryBot.build(:collection).user).to be_valid
  end


end
