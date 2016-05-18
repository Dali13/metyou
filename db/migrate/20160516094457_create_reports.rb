class CreateReports < ActiveRecord::Migration
  def change
    create_table :reports do |t|
      t.integer :reported_id
      t.integer :reporter_id
      t.text :report_message

      t.timestamps null: false
    end
    add_index :reports, :reported_id
    add_index :reports, :reporter_id
    add_index :reports, [:reported_id, :reporter_id], unique: true
  end
end
