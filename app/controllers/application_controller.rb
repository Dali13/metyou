class ApplicationController < ActionController::Base
  include PagesHelper
  include Pundit
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  

  # helper_method :resource_name, :resource, :devise_mapping
  
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

    private
  
    def user_not_authorized
      flash[:alert] = "You are not authorized to perform this action."
      redirect_to(request.referrer || root_path)
    end
    
    def confirmed_user
      if !current_user.confirmed?
      flash[:danger] = "Please confirm your account to continue"
      redirect_to root_url
      end
    end
    
    def admin_user
      if !current_user.admin?
      flash[:danger] = "Not authorized User"
      redirect_to root_url
      end
    end
    
    def get_count
      @unpublished_posts = Post.where(:published => false).size
    end
    # def owner_of?(user, post)
    #   return false unless (user.id == post.user_id)
    # end
      


end
