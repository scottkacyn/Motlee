class AddIndecesToComments < ActiveRecord::Migration
  def self.up
    change_table :comments do |t|
      t.index :commentable_id
      t.index :commentable_type
    end
  end

  def self.down
    remove_index :comments, :commentable_id
    remove_index :comments, :commentable_type
  end
end
