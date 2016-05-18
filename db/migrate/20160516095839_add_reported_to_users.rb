class AddReportedToUsers < ActiveRecord::Migration
  def change
    add_column :users, :reported, :boolean, default: false
  end
end
