class AddSectionNumberToUserTicket < ActiveRecord::Migration
  def change
    add_column :user_tickets, :section_number, :string
  end
end
