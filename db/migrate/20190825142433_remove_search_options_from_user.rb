class RemoveSearchOptionsFromUser < ActiveRecord::Migration
  def change
    remove_column :users, :search_options, :string
  end
end
