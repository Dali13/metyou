class User < ActiveRecord::Base
  require 'carrierwave/orm/activerecord'
  has_many :posts, dependent: :destroy
  mount_uploaders :avatars, AvatarUploader
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :confirmable, :lockable
         
         
    # private
    #   def self.logins_before_captcha
    #     3
    #   end
end
