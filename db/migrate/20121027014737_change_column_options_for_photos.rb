class ChangeColumnOptionsForPhotos < ActiveRecord::Migration
  def self.up
    change_column :photos, :lat, :decimal, :precision => 15, :scale => 10
    change_column :photos, :lon, :decimal, :precision => 15, :scale => 10
  end

  def self.down
    change_column :photos, :lat, :float
    change_column :photos, :lon, :float
  end
end
