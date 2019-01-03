class CreateTicketRelations < ActiveRecord::Migration
  def change
    create_table :ticket_relations do |t|
      t.belongs_to :user, index: true
      t.belongs_to :user_ticket, index: true
      t.boolean :manages
      t.timestamps null: false
    end
  end
end
