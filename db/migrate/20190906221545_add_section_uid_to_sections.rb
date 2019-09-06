class AddSectionUidToSections < ActiveRecord::Migration
  def change
    add_column :sections, :section_uid, :string
  end
end
