class AddDeleteFlagToEvents < ActiveRecord::Migration
  def self.up
    add_column :events, :is_deleted, :boolean
  end

  def self.down
    remove_column :events, :is_deleted
  end
end
