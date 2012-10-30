class AddLatLongToEvents < ActiveRecord::Migration
  def self.up
    add_column :events, :lat, :decimal, :precision => 15, :scale => 10
    add_column :events, :lon, :decimal, :precision => 15, :scale => 10
  end

  def self.down
    remove_column :events, :lat
    remove_column :events, :lon
  end
end
