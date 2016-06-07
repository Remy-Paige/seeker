class CreateDocuments < ActiveRecord::Migration
  def change
    create_table :documents do |t|
      t.string :url
      t.string :country
      t.integer :year
      t.integer :cycle

      t.timestamps null: false
    end
  end
end
