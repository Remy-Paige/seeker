class CollectionDocument < ActiveRecord::Base

  belongs_to :collection
  belongs_to :document

  validates :section_number, presence: true

end
