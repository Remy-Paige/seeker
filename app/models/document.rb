class Document < ActiveRecord::Base

  has_many :sections, dependent: :destroy
  belongs_to :country

  after_create :set_url_local

  DOCUMENT_TYPES = ['State Report', 'Committee of Experts Report', 'Committee of Ministers Recommendation']
  DOCUMENT_TYPES_ID = DOCUMENT_TYPES.zip(0...DOCUMENT_TYPES.length).to_h

  # url_local substitution before document is saved
  def clean_url
    "public/storage/#{self.url.gsub(/https?:\/\//, '')}"
  end

  def url_text
    self.url_local&.gsub(/\.pdf$/i, '.txt') || self.clean_url&.gsub(/\.pdf$/i, '.txt')
  end

  def finish_parsing!
    self.update_attributes(parsing_finished: true)
  end

  private

  def set_url_local
    self.update_attributes(url_local: self.clean_url)
  end
end
