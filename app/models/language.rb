class Language < ActiveRecord::Base

  has_many :sections
  belongs_to :country
end
