class AddLonToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :lon, :float
  end
end
