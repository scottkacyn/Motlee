class CreateLikes < ActiveRecord::Migration
  def self.up
    create_table :likes do |t|
      t.references :user
      t.references :like_thread
      t.boolean :is_active

      t.timestamps
    end
  end

  def self.down
    drop_table :likes
  end
end
