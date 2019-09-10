class RemoveSectionNumberFromCollectionDocuments < ActiveRecord::Migration
  def change
    remove_column :collection_documents, :section_number, :string
  end
end
