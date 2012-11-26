class RemoveColumnsFromPhotos < ActiveRecord::Migration
  def self.up
    remove_column :photos, :thumbnail
    remove_column :photos, :source
    remove_column :photos, :height
    remove_column :photos, :width
  end

  def self.down
    add_column :photos, :width, :integer
    add_column :photos, :height, :integer
    add_column :photos, :source, :string
    add_column :photos, :thumbnail, :string
  end
end
