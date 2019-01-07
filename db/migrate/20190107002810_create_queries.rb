class CreateQueries < ActiveRecord::Migration
  def change
    create_table :queries do |t|
      t.belongs_to :collection, index: true
      t.text :query
      t.timestamps null: false
    end
  end
end
