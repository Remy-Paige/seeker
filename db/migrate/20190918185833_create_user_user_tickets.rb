class CreateUserUserTickets < ActiveRecord::Migration
  def change
    create_table :user_user_tickets do |t|
      t.belongs_to :user, index: true
      t.belongs_to :user_ticket, index: true
      t.timestamps null: false
    end
  end
end
