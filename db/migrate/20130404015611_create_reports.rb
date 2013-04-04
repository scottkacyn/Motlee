class CreateReports < ActiveRecord::Migration
  def change
    create_table :reports do |t|
      t.string :object
      t.integer :object_id
      t.references :user

      t.timestamps
    end
    add_index :reports, :user_id
  end
end
