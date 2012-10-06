class RemoveIsActiveFromFomos < ActiveRecord::Migration
  def self.up
    remove_column :fomos, :is_active
  end

  def self.down
    add_column :fomos, :is_active, :boolean
  end
end
