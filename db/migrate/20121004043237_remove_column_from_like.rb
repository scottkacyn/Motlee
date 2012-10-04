class RemoveColumnFromLike < ActiveRecord::Migration
  def self.up
    remove_column :likes, :like_thread_id
  end

  def self.down
    add_column :lies, :like_thread_id, :integer
  end
end
