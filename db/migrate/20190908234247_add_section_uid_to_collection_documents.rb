class AddSectionUidToCollectionDocuments < ActiveRecord::Migration
  def change
    add_column :collection_documents, :section_uid, :string
  end
end
