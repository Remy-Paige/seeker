class UserTicket < ActiveRecord::Base


  belongs_to :document
  # document has many user_ticket

  has_many :user_user_tickets
  has_many :users, through: :user_user_tickets

  before_destroy { users.clear }


  STATUS_TYPES = ['Unmanaged', 'Open', 'Resolved']
  STATUS_TYPES_ID = STATUS_TYPES.zip(0...STATUS_TYPES.length).to_h

  SUBJECT_TYPES = ['meta-data error', 'sectioning error', 'document request', 'other']

  validates :comment, presence: true

  def claim(user)

    if self.status == 0
      self.status = 1
      self.save
      user.user_tickets << self
    end
  end

  def resolve

    self.status = 2
    self.save

  end

end
