class User < ActiveRecord::Base
  has_many :posts, dependent: :destroy
  has_many :albums, dependent: :destroy
  has_many :sent_messages, class_name: "Message",
                          foreign_key: "sender_id",
                          dependent: :destroy
  has_many :reply_posts, through: :sent_messages
  #has_many :posts, through: :messages
  # validate :albums_count_within_bounds, on: :update
  accepts_nested_attributes_for :albums
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :confirmable, :lockable
         
         
    # private
    
    # def albums_count_within_bounds
    #   return if self.albums.blank?
    #   errors.add(:base, "Too many photos") if self.albums.size > 1
    # end
    #   def self.logins_before_captcha
    #     3
    #   end
end
