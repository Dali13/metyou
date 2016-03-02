class MessageMailer < ApplicationMailer
  
    def message_email(message_id)
    message = Message.find(message_id)
    @sender = User.find(message.sender_id)
    @post = Post.find(message.reply_post_id)
    @receiver = User.find(@post.user_id)
    #@url  = 'http://example.com/login'
    mail(to: @receiver.email, reply_to: @receiver.email, subject: 'You have a new message for your post')
    end
    
end
