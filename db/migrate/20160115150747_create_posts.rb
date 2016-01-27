class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts do |t|
      t.string :title, null: false
      t.string :city
      t.string :postal_code
      t.date :meeting_date
      t.text :description, null: false
      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
