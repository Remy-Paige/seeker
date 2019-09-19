class AddSectionUidToUserTickets < ActiveRecord::Migration
  def change
    add_column :user_tickets, :section_uid, :string
  end
end
