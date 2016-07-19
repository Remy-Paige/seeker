class AddSectionPartToSection < ActiveRecord::Migration
  def change
    add_column :sections, :section_part, :integer
  end
end
