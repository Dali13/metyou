class AddIndexToPosts < ActiveRecord::Migration
  def change
    add_index :posts, :gender
  end
end
