class AddChapterToSections < ActiveRecord::Migration
  def change
    add_column :sections, :chapter, :integer
  end
end
