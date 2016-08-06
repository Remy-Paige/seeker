class Language < ActiveRecord::Base

  has_many :sections
  has_and_belongs_to_many :countries

  default_scope { order('name ASC') }

  def to_s
    self.name
  end
end
