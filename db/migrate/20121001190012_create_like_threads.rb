class CreateLikeThreads < ActiveRecord::Migration
  def self.up
    create_table :like_threads do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :like_threads
  end
end
