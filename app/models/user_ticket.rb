class UserTicket < ActiveRecord::Base

  has_many :ticket_relations
  has_many :users, through: :ticket_relations

  belongs_to :document

  before_destroy { users.clear }

  STATUS_TYPES = ['Unmanaged', 'Open']
  STATUS_TYPES_ID = STATUS_TYPES.zip(0...STATUS_TYPES.length).to_h

  SUBJECT_TYPES = ['meta-data error', 'sectioning error', 'document request', 'other']


end
