class Country < ActiveRecord::Base

  has_many :documents
  has_many :languages

  def to_s
    self.name
  end
end
