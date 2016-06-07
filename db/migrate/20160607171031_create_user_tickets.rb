class CreateUserTickets < ActiveRecord::Migration
  def change
    create_table :user_tickets do |t|
      t.string :name
      t.string :email
      t.string :link
      t.text :comment
      t.integer :status
      t.integer :admin_id

      t.timestamps null: false
    end
  end
end
