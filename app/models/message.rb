class Message < ActiveRecord::Base
  belongs_to :sender, class_name: "User"
  belongs_to :reply_post, class_name: "Post"
  validates :content, presence: true, length: { minimum: 5, maximum: 400}
  attr_accessor :verification
end
