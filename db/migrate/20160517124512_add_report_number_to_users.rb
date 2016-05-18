class AddReportNumberToUsers < ActiveRecord::Migration
  def change
    add_column :users, :report_number, :integer, default: 0
    add_index :users, :report_number
  end
end
