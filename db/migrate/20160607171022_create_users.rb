class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.integer :role
      t.string :email
      t.string :name
      t.string :search_options

      t.timestamps null: false
    end
  end
end
