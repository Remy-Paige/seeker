class AddFeedbackToQueries < ActiveRecord::Migration
  def change
    add_column :queries, :feedback, :text
  end
end
