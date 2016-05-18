class User < ActiveRecord::Base
  has_many :posts, dependent: :destroy
  has_many :albums, dependent: :destroy
  has_many :photos, dependent: :destroy
  has_many :sent_messages, class_name: "Message",
                          foreign_key: "sender_id",
                          dependent: :destroy
  has_many :reply_posts, through: :sent_messages
  has_many :active_relationships, class_name:  "Relationship",
                                  foreign_key: "follower_id",
                                  dependent:   :destroy
  has_many :following, through: :active_relationships, source: :followed
  
  has_many :reports, foreign_key: "reported_id",
                     dependent: :destroy
  has_many :reporters, through: :reports, source: :reporter
  scope :desc_order, -> { order(created_at: :desc) }
  scope :desc_report_order, -> { order(report_number: :desc) }
  #has_many :posts, through: :messages
  # validate :albums_count_within_bounds, on: :update
  accepts_nested_attributes_for :albums
  # validates :uid, presence: true
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :uid, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :confirmable, :lockable, :async
         
         
    def owner_of?(post)
      if (self.id == post.user_id)
        return true
      else
        return false
      end
    end
    
    def to_param
      self.uid
    end
    
    def follow(other_user)
      active_relationships.create(followed_id: other_user.id)
    end
    
    def following?(other_user)
      following.include?(other_user)
    end
    
    def self.logins_before_captcha
    3
    end
    
    def active_for_authentication?
      super && !self.blocked?
    end
    
    
    private
    

    def find_by_uid(param)
      self.find_by(uid: param)
    end
    # def albums_count_within_bounds
    #   return if self.albums.blank?
    #   errors.add(:base, "Too many photos") if self.albums.size > 1
    # end
    #   def self.logins_before_captcha
    #     3
    #   end
end
