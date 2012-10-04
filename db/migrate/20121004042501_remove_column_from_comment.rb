class RemoveColumnFromComment < ActiveRecord::Migration
  def self.up
    remove_column :comments, :comment_thread_id
  end

  def self.down
    add_column :comments, :comment_thread_id, :integer
  end
end
