class AddRemoteAvatarUrlToAlbums < ActiveRecord::Migration
  def change
    add_column :albums, :remote_avatar_url, :string
  end
end
