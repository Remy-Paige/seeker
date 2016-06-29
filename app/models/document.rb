class Document < ActiveRecord::Base

  has_many :sections

  after_update :set_url_local

  # url_local substitution before document is saved
  def clean_url
    "public/storage/#{self.url.gsub(/https?:\/\//, '')}"
  end

  def url_text
    self.url_local&.gsub(/\.pdf$/i, '.txt') || self.clean_url&.gsub(/\.pdf$/i, '.txt')
  end

  private

  def set_url_local
    self.update_attributes(url_local: self.clean_url)
  end
end
