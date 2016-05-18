class CleaningJob < ActiveJob::Base  

  def perform
    Post.where('updated_at < ?', 60.days.ago).each do |post|
      post.destroy
    end
  end
end  