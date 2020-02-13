class AddManagesOwnsToUserUserTickets < ActiveRecord::Migration
  def change
    add_column :user_user_tickets, :manages_owns, :boolean
  end
end
