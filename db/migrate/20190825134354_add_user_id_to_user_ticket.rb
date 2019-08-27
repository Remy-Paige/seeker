class AddUserIdToUserTicket < ActiveRecord::Migration
  def change
    add_reference :user_tickets, :user, index: true
    add_foreign_key :user_tickets, :users
  end
end
