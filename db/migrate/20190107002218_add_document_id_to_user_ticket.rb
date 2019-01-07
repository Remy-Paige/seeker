class AddDocumentIdToUserTicket < ActiveRecord::Migration
  def change
    add_column :user_tickets, :document_id, :integer
    add_index :user_tickets, :document_id
  end
end
