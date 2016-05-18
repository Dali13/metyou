class AddFlagNumberToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :flag_number, :integer, default: 0
    add_index :posts, :flag_number
  end
end
