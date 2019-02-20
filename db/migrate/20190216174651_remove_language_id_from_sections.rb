class RemoveLanguageIdFromSections < ActiveRecord::Migration
  def change
    remove_column :sections, :language_id, :integer
  end
end
