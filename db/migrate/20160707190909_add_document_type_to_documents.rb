class AddDocumentTypeToDocuments < ActiveRecord::Migration
  def change
    add_column :documents, :document_type, :integer
  end
end
