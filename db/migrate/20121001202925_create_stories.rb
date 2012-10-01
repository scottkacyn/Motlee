class CreateStories < ActiveRecord::Migration
  def self.up
    create_table :stories do |t|
      t.references :user
      t.references :event
      t.text :body
      t.references :comment_thread
      t.references :like_thread

      t.timestamps
    end
  end

  def self.down
    drop_table :stories
  end
end
