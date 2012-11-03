class AddUidToFomosTable < ActiveRecord::Migration
  def self.up
    add_column :fomos, :uid, :string
    add_column :fomos, :name, :string
  end

  def self.down
	  remove_column :fomos, :uid
	  remove_column :fomos, :name
  end
end
