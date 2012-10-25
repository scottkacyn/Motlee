class AddColumnToComments < ActiveRecord::Migration
  def self.up
    add_column :comments, :comment_thread_id, :integer
  end

  def self.down
    remove_column :comments, :comment_thread_id
  end
end
