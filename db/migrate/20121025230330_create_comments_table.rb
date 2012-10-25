class CreateCommentsTable < ActiveRecord::Migration
  def self.up
    create_table :comments do |t|
	    t.references :user
	    t.text :body
	    t.integer :commentable_id
	    t.string :commentable_string
    end
  end

  def self.down
	  drop_table :comments
  end
end
