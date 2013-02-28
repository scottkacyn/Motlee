class FixColumnTypeName < ActiveRecord::Migration
  def self.up
    rename_column :devices, :type, :device_type
  end

  def self.down
  end
end
