class Album < ActiveRecord::Base
  # require 'uri_validator'
  attr_accessor :remote_avatar_url
  # validates :avatar, presence: true
  belongs_to :user
  mount_uploader :avatar, AvatarUploader
    # validates :remote_avatar_url, 
    # :uri => { 
    #   # :format => /(^$)|(^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?$)/ix,
    #   :allow_blank => true
    # }
  #validate :avatars_count_within_bounds, :on => :create
  # validates_uniqueness_of :user_id
  # validate :avatar_size
  # validates_associated :user
  before_save :check_url
  after_save :process_async
  
      private
      
      def check_url
        self.image_processing = true if new_record? && original_avatar_url
      end
      
      def process_async
        ProcessImageWorker.perform_async(self.id, original_avatar_url) if original_avatar_url && image_processing
      end
  
      # private
    
        # def avatars_count_within_bounds
        #   user = self.user
        #   return if user.albums.blank?
        #   if user.albums.size > 1
        #     errors.add(:avatar, "Too many photos") 
        #   end
        # end
        
        # Validates the size of an uploaded avatar
        # def avatar_size
        #   if avatar.size > 5.megabytes
        #     errors.add(:avatar, "should be less than 5MB")
        #   end
        # end
        
end