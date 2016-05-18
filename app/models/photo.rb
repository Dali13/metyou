class Photo < ActiveRecord::Base
  belongs_to :user
  attr_accessor :remote_image_url
  mount_uploader :image, ImageUploader
  validates_uniqueness_of :user_id
  before_create :check_url
  after_commit :process_async, :on => :create 
  before_destroy :delete_original_image
  
  
      private
      
      def check_url
        self.image_processing = true if new_record? && original_image_url
      end
      
      def process_async
        ProcessPhotoWorker.perform_async(self.id, original_image_url) if original_image_url && image_processing
      end
      
      def delete_original_image
        if !self.original_image_url.blank?
          key = self.original_image_url.split('amazonaws.com/')[1]
          S3_BUCKET.object(key).delete
        end
      end
end
