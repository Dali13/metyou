class AddFlagedToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :flaged, :boolean, default: false
  end
end
