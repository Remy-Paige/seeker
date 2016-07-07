class ChangeCountryToReference < ActiveRecord::Migration
  def up
    rename_column :languages, :country, :country_id
    change_column :languages, :country_id, 'integer USING country_id::integer'
    add_index :languages, :country_id
    rename_column :documents, :country, :country_id
    change_column :documents, :country_id, 'integer USING country_id::integer'
    add_index :documents, :country_id
  end

  def down
    remove_index :languages, :country_id
    rename_column :languages, :country_id, :country
    change_column :languages, :country, :string
    remove_index :documents, :country_id
    rename_column :documents, :country_id, :country
    change_column :documents, :country, :string
  end
end
