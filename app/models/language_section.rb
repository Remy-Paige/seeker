class LanguageSection < ActiveRecord::Base

  belongs_to :section
  belongs_to :language

  STRENGTH_TYPES = ['Human Confirmed', 'Strong', 'Medium', 'Weak']
  STRENGTH_TYPES_ID = STRENGTH_TYPES.zip(0...STRENGTH_TYPES.length).to_h

end
