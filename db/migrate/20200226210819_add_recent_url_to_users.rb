class AddRecentUrlToUsers < ActiveRecord::Migration
  def change
    add_column :users, :recent_url, :string
  end
end
