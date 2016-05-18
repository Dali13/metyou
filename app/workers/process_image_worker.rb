class ProcessImageWorker
 include Sidekiq::Worker
 sidekiq_options :retry => 5

  def perform(album_id, url)
      if url.include? "amazonaws.com/"
        Album.find(album_id).tap do |album| # 1
          album.remote_avatar_url = 'http:' + url      # 2
          album.image_processing = nil      # 3
          album.save!                       # 4
        end
      else
        Album.find(album_id).delete
      end
  end
end