class TicketRelation < ActiveRecord::Base

  belongs_to :user
  belongs_to :user_ticket

end
