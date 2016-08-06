class CountriesLanguagesManyToMany < ActiveRecord::Migration
  def up
    remove_index :languages, :country_id
    remove_column :languages, :country_id

    create_table :countries_languages, id: false do |t|
      t.belongs_to :country, index: true
      t.belongs_to :language, index: true
    end
  end

  def down
    drop_table :countries_languages

    add_column :languages, :country_id, :integer
    add_index :languages, :country_id
  end
end
