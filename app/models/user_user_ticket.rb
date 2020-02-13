class UserUserTicket < ActiveRecord::Base

  belongs_to :user
  belongs_to :user_ticket


#   0 = owns
#   1 = manages

end
