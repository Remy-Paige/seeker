require 'rails_helper'

RSpec.describe CollectionDocument, type: :model do


  it "has a valid factory" do
    expect(FactoryBot.create(:collection_document)).to be_valid
  end

  it "is invalid without a section_number" do
    expect(FactoryBot.build(:collection_document, section_number: nil)).not_to be_valid
  end


  # the section number exists in the document referenced

  #   create_table "collection_documents", force: :cascade do |t|
  #     t.integer  "collection_id"
  #     t.integer  "document_id"
  #     t.string   "section_number"
  #     t.datetime "created_at",     null: false
  #     t.datetime "updated_at",     null: false
  #   end


end
