class ProcessPhotoWorker
 include Sidekiq::Worker
 sidekiq_options :retry => 5

  def perform(photo_id, url)
      if url.include? "amazonaws.com/"
        Photo.find(photo_id).tap do |photo| # 1
          photo.remote_image_url = 'http:' + url      # 2
          photo.image_processing = nil      # 3
          photo.save!                       # 4
        end
      else
        Photo.find(photo_id).delete
      end
  end
end