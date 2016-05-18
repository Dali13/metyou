class AddLatToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :lat, :float
  end
end
