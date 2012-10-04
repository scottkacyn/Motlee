class DropTableComments < ActiveRecord::Migration
  def self.up
    drop_table :comments
  end

  def self.down
    create_table :comments do |t|
	t.string :body
	t.references :user
	t.references :commentable, :polymorphic => true
	t.timestamps
    end
  end
end
