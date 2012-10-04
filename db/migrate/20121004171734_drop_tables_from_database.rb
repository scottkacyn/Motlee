class DropTablesFromDatabase < ActiveRecord::Migration
  def self.up
    drop_table :like_threads
    drop_table :comment_threads
  end

  def self.down
  end
end
