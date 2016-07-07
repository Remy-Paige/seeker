class Country < ActiveRecord::Base

  has_many :documents
  has_many :languages
end
