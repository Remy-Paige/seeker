class Section < ActiveRecord::Base

  belongs_to :document
  belongs_to :language
end
