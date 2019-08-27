class DropTicketRelations < ActiveRecord::Migration
  def change
    drop_table :ticket_relations
  end
end
