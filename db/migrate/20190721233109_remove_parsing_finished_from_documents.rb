class RemoveParsingFinishedFromDocuments < ActiveRecord::Migration
  def change
    remove_column :documents, :parsing_finished, :boolean
  end
end
