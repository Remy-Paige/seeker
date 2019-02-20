class Language < ActiveRecord::Base

  has_many :language_sections
  has_many :sections, through: :language_sections

  has_and_belongs_to_many :countries

  before_destroy {sections.clear}

  default_scope { order('name ASC') }

  def to_s
    self.name
  end
end
