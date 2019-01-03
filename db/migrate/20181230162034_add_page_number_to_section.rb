class AddPageNumberToSection < ActiveRecord::Migration
  def change
    add_column :sections, :page_number, :integer
  end
end
