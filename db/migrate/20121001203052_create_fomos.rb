class CreateFomos < ActiveRecord::Migration
  def self.up
    create_table :fomos do |t|
      t.references :user
      t.references :event
      t.boolean :is_active

      t.timestamps
    end
  end

  def self.down
    drop_table :fomos
  end
end
