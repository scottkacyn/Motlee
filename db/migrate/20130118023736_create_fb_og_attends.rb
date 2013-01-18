class CreateFbOgAttends < ActiveRecord::Migration
  def self.up
    create_table :fb_og_attends do |t|
      t.references :event
      t.long :fb_attend_id

      t.timestamps
    end
  end

  def self.down
    drop_table :fb_og_attends
  end
end
