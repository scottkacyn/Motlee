class DropLikesTable < ActiveRecord::Migration
  def self.up
    drop_table :likes
    create_table :likes do |t|
      t.references :user
      t.belongs_to :likeable, polymorphic: true

      t.timestamps
    end
    add_index :likes, [:likeable_id, :likeable_type]
  end

  def self.down
    drop_table :likes
    create_table :likes do |t|
      t.references :user
      t.belongs_to :likeable, polymorphic: true

      t.timestamps
    end
    add_index :likes, [:likeable_id, :likeable_type]
  end
end
