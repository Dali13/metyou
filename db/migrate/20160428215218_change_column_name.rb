class ChangeColumnName < ActiveRecord::Migration
  def change
    rename_column :albums, :avatar, :original_avatar_url
  end
end
