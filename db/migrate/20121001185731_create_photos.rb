class CreatePhotos < ActiveRecord::Migration
  def self.up
    create_table :photos do |t|
      t.references :user
      t.references :event
      t.string :caption
      t.string :thumbnail
      t.string :source
      t.integer :height
      t.integer :width
      t.float :lat
      t.float :lon
      t.references :comment_thread
      t.references :like_thread

      t.timestamps
    end
  end

  def self.down
    drop_table :photos
  end
end
