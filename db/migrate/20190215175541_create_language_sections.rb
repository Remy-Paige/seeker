class CreateLanguageSections < ActiveRecord::Migration
  def change
    create_table :language_sections do |t|
      t.belongs_to :section, index: true
      t.belongs_to :language, index: true
      t.integer :strength
      t.timestamps null: false
    end
  end
end
