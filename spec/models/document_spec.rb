require 'rails_helper'

RSpec.describe Document, type: :model do

  it "has a valid factory" do
    expect(FactoryGirl.create(:document)).to be_valid
  end

  # url is user input - what if its formatted wrong?

  describe '#clean_url' do

    it "replaces https:// and http:// with public/storage/" do
      expect(FactoryGirl.build(:document, url: 'http://www.coe.int/t').clean_url).to eq('public/storage/www.coe.int/t')
      expect(FactoryGirl.build(:document, url: 'https://www.coe.int/t').clean_url).to eq('public/storage/www.coe.int/t')
    end

  end


  describe '#url_text' do

    it "replaces '.pdf' or '' at the end of the url with .txt" do
      expect(FactoryGirl.build(:document, url: 'http://www.coe.int/t.pdf').url_text).to eq('public/storage/www.coe.int/t.txt')
      expect(FactoryGirl.build(:document, url: 'https://www.coe.int/t').url_text).to eq('public/storage/www.coe.int/t.txt')
    end

  end

  describe '#finish_parsing!' do
    pending
  end

  #after create
  describe '#download_and_set_url_local' do

    # it "creates a folder based on the url" do
    #   pending
    # end

    it "raises an error if the url fetches nothing" do
      expect { expect(FactoryGirl.build(:document, url: 'https://rosan.co.uk/').download_and_set_url_local)}.to raise_error
    end

    it "raises an error if the url is html" do
      url = 'https://rm.coe.int/CoERMPublicCommonSearchServices/documentAccessError.jsp?url=http://rm.coe.int:80/CoERMPublicCommonSearchServices/sso/SSODisplayDCTMContent?documentId=09000016805d4b12'
      expect { expect(FactoryGirl.build(:document, url: url).download_and_set_url_local)}.to raise_error
      expect { expect(FactoryGirl.build(:document, url: 'rpaige.co.uk').download_and_set_url_local)}.to raise_error
    end

    # it "downloads the file if the url has a pdf" do
    #
    #
    #   subject {FactoryGirl.create(:document)}
    #
    #   subject.download_and_set_url_local
    #
    #   expect(File.exist?(clean_url)).to be_truthy
    #
    # end

    # it "updates the database" do
    #   pending
    # end

    describe '#delete_local_documents' do
      pending
    end

  end




#   validates :url, presence: true
#   validates :country_id, presence: true
#   validates :document_type, presence: true, numericality: true, inclusion: { in: (0...DOCUMENT_TYPES.length).to_a }
#   validates :year, presence: true, numericality: true
#   validates :cycle, presence: true, numericality: true

end