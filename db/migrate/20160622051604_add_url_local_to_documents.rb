class AddUrlLocalToDocuments < ActiveRecord::Migration
  def change
    add_column :documents, :url_local, :string
  end
end
