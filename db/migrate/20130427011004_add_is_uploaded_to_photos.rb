class AddIsUploadedToPhotos < ActiveRecord::Migration
  def change
    add_column :photos, :is_uploaded, :boolean
  end
end
