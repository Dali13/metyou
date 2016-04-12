class MessageMailer < ApplicationMailer
  
    def message_email(message_id)
    @reply_message = Message.find(message_id)
    @sender = @reply_message.sender
    @post = @reply_message.reply_post
    @receiver = @post.user
    #@url  = 'http://example.com/login'
    mail(to: @receiver.email, reply_to: @receiver.email, subject: 'You have a new message for your post')
    end
    
end
