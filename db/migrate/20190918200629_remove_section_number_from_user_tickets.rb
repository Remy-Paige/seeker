class RemoveSectionNumberFromUserTickets < ActiveRecord::Migration
  def change
    remove_column :user_tickets, :section_number, :string
  end
end
