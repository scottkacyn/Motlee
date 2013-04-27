class CreateFavorites < ActiveRecord::Migration
  def change
    create_table :favorites do |t|
      t.references :user
      t.references :event

      t.timestamps
    end
    add_index :favorites, :user_id
    add_index :favorites, :event_id
  end
end
