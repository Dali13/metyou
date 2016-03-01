module PostsHelper
  
  def owner(post)
      if (current_user.id == post.user_id)
        return true
      else
        return false
      end
  end
end
