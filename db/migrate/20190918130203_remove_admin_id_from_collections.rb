class RemoveAdminIdFromCollections < ActiveRecord::Migration
  def change
    remove_column :collections, :admin_id, :integer
  end
end
