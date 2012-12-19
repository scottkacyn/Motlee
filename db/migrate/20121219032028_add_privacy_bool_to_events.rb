class AddPrivacyBoolToEvents < ActiveRecord::Migration
  def self.up
    add_column :events, :is_private, :boolean
  end

  def self.down
    remove_column :events, :is_private
  end
end
