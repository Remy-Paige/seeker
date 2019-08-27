class UserTicket < ActiveRecord::Base


  belongs_to :document
  # document has many user_ticket

  # either user only or user and admin
  belongs_to :user
  belongs_to :admin


  STATUS_TYPES = ['Unmanaged', 'Open', 'Resolved']
  STATUS_TYPES_ID = STATUS_TYPES.zip(0...STATUS_TYPES.length).to_h

  SUBJECT_TYPES = ['meta-data error', 'sectioning error', 'document request', 'other']

  validates :comment, presence: true

  def claim(user)

    self.admin_id = user
    self.status = 1
    self.save

  end

  def resolve

    self.status = 2
    self.save

  end

end
