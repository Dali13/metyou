class AddImageProcessingToAlbums < ActiveRecord::Migration
  def change
    add_column :albums, :image_processing, :boolean, :default => nil
  end
end
