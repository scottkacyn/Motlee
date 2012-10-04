class CreateComments < ActiveRecord::Migration
  def self.up
    create_table :comments do |t|
      t.references :user
      t.references :comment_thread
      t.string :body

      t.timestamps
    end
  end

  def self.down
    drop_table :comments
  end
end
