class CreateCollectionDocuments < ActiveRecord::Migration
  def change
    create_table :collection_documents do |t|
      t.belongs_to :collection, index: true
      t.belongs_to :document, index: true
      t.string :section_number
      t.timestamps null: false
    end
  end
end
