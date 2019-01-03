class AddSubjectToUserTickets < ActiveRecord::Migration
  def change
    add_column :user_tickets, :subject, :string
  end
end
