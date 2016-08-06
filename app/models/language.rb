class Language < ActiveRecord::Base

  has_many :sections
  has_and_belongs_to_many :countries
end
