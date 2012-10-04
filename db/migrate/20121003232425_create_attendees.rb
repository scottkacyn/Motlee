class CreateAttendees < ActiveRecord::Migration
  def self.up
    create_table :attendees do |t|
      t.references :user
      t.references :event
      t.integer :rsvp_status

      t.timestamps
    end
  end

  def self.down
    drop_table :attendees
  end
end
