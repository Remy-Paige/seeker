class AddArticleParagraphToSections < ActiveRecord::Migration
  def change
    add_column :sections, :article_paragraph, :string
  end
end
