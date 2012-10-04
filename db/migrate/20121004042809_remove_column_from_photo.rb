class RemoveColumnFromPhoto < ActiveRecord::Migration
  def self.up
    remove_column :photos, :comment_thread_id
    remove_column :photos, :like_thread_id
  end

  def self.down
    add_column :photos, :comment_thread_id, :integer
    add_column :photos, :like_thread_id, :integer
  end
end
