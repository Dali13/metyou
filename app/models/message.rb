class Message < ActiveRecord::Base
  belongs_to :sender, class_name: "User"
  belongs_to :reply_post, class_name: "Post"
end
