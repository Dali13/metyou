class RemoveRemoteAvatarUrlFromAlbums < ActiveRecord::Migration
  def change
    remove_column :albums, :remote_avatar_url, :string
  end
end
