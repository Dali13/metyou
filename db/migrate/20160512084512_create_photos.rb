class CreatePhotos < ActiveRecord::Migration
  def change
    create_table :photos do |t|
      t.string :image, null: false
      t.references :user, index: true, foreign_key: true
      t.string :original_image_url, null: false
      t.boolean :image_processing, :default => nil

      t.timestamps null: false
    end
  end
end
