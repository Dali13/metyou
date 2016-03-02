class Album < ActiveRecord::Base
  validates :avatar, presence: true
  belongs_to :user
  mount_uploader :avatar, AvatarUploader
  #validate :avatars_count_within_bounds, :on => :create
  validates_uniqueness_of :user_id
  validate :avatar_size
  # validates_associated :user
  
      private
    
        # def avatars_count_within_bounds
        #   user = self.user
        #   return if user.albums.blank?
        #   if user.albums.size > 1
        #     errors.add(:avatar, "Too many photos") 
        #   end
        # end
        
        # Validates the size of an uploaded avatar
        def avatar_size
          if avatar.size > 5.megabytes
            errors.add(:avatar, "should be less than 5MB")
          end
        end
        
end