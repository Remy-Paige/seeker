class CreateSections < ActiveRecord::Migration
  def change
    create_table :sections do |t|
      t.references :document, index: true
      t.text :section_name
      t.text :content
      t.references :language, index: true

      t.timestamps null: false
    end
  end
end
