class User < ActiveRecord::Base
  has_many :posts, dependent: :destroy
  has_many :albums, dependent: :destroy
  accepts_nested_attributes_for :albums
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
