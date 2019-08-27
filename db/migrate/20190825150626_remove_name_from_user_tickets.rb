class RemoveNameFromUserTickets < ActiveRecord::Migration
  def change
    remove_column :user_tickets, :name, :string
  end
end
