class AddIsPrivateToUser < ActiveRecord::Migration
  def change
    add_column :users, :is_private, :boolean
  end
end
