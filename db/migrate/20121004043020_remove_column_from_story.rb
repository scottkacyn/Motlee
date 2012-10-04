class RemoveColumnFromStory < ActiveRecord::Migration
  def self.up
    remove_column :stories, :comment_thread_id
    remove_column :stories, :like_thread_id
  end

  def self.down
    add_column :stories, :comment_thread_id, :integer
    add_column :stories, :like_thread_id, :integer
  end
end
