class ProcessImageWorker
 include Sidekiq::Worker

  def perform(album_id, url)
    Album.find(album_id).tap do |album| # 1
      album.remote_avatar_url = 'http:' + url      # 2
      album.image_processing = nil      # 3
      album.save!                       # 4
    end
  end
end