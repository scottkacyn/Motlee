class AddColumnToLocations < ActiveRecord::Migration
  def self.up
    add_column :locations, :uid, :string
  end

  def self.down
    remove_column :locations, :uid
  end
end
