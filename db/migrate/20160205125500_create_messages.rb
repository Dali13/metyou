class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.integer :sender_id
      t.integer :reply_post_id
      t.text :content

      t.timestamps null: false
    end
  add_index :messages, :sender_id
  add_index :messages, :reply_post_id
  add_index :messages, [:sender_id, :reply_post_id], unique: true
  end
end
