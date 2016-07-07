class AddParsingFinishedToDocuments < ActiveRecord::Migration
  def change
    add_column :documents, :parsing_finished, :boolean, default: false
  end
end
