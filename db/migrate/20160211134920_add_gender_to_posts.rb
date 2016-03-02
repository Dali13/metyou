class AddGenderToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :gender, :string
  end
end
