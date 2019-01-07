class CollectionDocument < ActiveRecord::Base

  belongs_to :collection
  belongs_to :document

end
