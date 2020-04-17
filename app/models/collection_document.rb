class CollectionDocument < ActiveRecord::Base

  belongs_to :collection
  belongs_to :document

  # do not validate because then adding a relation and then editing it to add the attribute breaks
  # validate that the section number is present after relation addition in the tests
  # validates :section_number, presence: true

end
