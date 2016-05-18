class CreateFlags < ActiveRecord::Migration
  def change
    create_table :flags do |t|
      t.integer :flaged_id
      t.integer :flager_id
      t.text :flag_message

      t.timestamps null: false
    end
    add_index :flags, :flaged_id
    add_index :flags, :flager_id
    add_index :flags, [:flaged_id, :flager_id], unique: true
  end
end
