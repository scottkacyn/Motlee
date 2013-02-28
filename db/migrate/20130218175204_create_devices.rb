class CreateDevices < ActiveRecord::Migration
  def self.up
    create_table :devices do |t|
      t.references :user
      t.string :device_id
      t.string :type

      t.timestamps
    end
  end

  def self.down
    drop_table :devices
  end
end
