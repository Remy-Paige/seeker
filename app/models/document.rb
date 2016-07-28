require 'open-uri'

class Document < ActiveRecord::Base

  has_many :sections, dependent: :destroy
  belongs_to :country

  after_create :download_and_set_url_local
  before_destroy :delete_local_documents

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

  def download_and_set_url_local
    dir = self.clean_url.split('/')[0...-1].join('/')
    FileUtils.mkdir_p(dir)
    IO.copy_stream(open(self.url), self.clean_url)
    self.update_attributes(url_local: self.clean_url)
  end

  def delete_local_documents
    FileUtils.rm(self.url_local)
    FileUtils.rm(self.url_text)
  end
end
