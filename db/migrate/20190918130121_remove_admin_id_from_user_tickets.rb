class RemoveAdminIdFromUserTickets < ActiveRecord::Migration
  def change
    remove_column :user_tickets, :admin_id, :integer
  end
end
