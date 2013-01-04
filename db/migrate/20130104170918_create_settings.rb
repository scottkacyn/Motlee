class CreateSettings < ActiveRecord::Migration
  def self.up
    create_table :settings do |t|
      t.boolean :fb_on_event_create
      t.boolean :fb_on_event_invite
      t.boolean :on_event_invite
      t.boolean :on_event_message
      t.boolean :on_photo_comment
      t.boolean :on_photo_like
      t.boolean :on_friend_join

      t.timestamps
    end
  end

  def self.down
    drop_table :settings
  end
end
