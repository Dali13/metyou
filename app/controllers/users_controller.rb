class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_s3_direct_post, only: [:edit]
  invisible_captcha only: [:post_report], honeypot: :verification
  #before_action :admin_user, only: [:index]
  #before_action :correct_user, only: [:show, :edit, :update]

def show
  if @user = User.find_by_uid(params[:id])
    authorize @user
    @album = Album.find_by(user_id: @user.id)
  else
    redirect_to root_url
  end
end

def edit
  if @user = User.find_by_uid(params[:id])
    authorize @user
    @album = @user.albums.build
    @photo = @user.photos.build
    if @user.albums.count > 0 
      @album_existant = @user.albums.first
      # @avatar = Album.find_by(user_id: @user.id).avatar
    else
      @album_existant = nil
    end
    if @user.photos.count > 0 
      @photo_existant = @user.photos.first
      # @avatar = Album.find_by(user_id: @user.id).avatar
    else
      @photo_existant = nil
    end
  else
   redirect_to root_url    
  end
end

def update
  @user = User.find_by_uid(params[:id])
  authorize @user

  if !params.has_key?(:albums) && !params.has_key?(:photos)
    if @user.update_attributes(edit_user_params)
      flash[:success] = 'Your profile was updated'
      redirect_to user_path(@user)
    else
      flash[:danger] = 'An error has occured, Please try again!'
      redirect_to edit_user_path(@user)
    end
  else
    if !params.has_key?(:photos)
      if (@user.update_attributes(edit_user_params) && @user.albums.create(:original_avatar_url => params[:albums]['original_avatar_url'], :user_id => @user.id))
          flash[:success] = 'Your profile and photo was updated'
          redirect_to user_path(@user)
      else
        flash[:danger] = 'An error has occured, Please try again!'
        redirect_to edit_user_path(@user)
      end
    else
      if !params.has_key?(:albums)
        if (@user.update_attributes(edit_user_params) && @user.photos.create(:original_image_url => params[:photos]['original_image_url'], :user_id => @user.id))
            flash[:success] = 'Your profile and photo was updated'
            redirect_to user_path(@user)
        else
          flash[:danger] = 'An error has occured, Please try again!'
          redirect_to edit_user_path(@user)
        end
      else
        if (@user.update_attributes(edit_user_params) && @user.photos.create(:original_image_url => params[:photos]['original_image_url'], :user_id => @user.id) && @user.albums.create(:original_avatar_url => params[:albums]['original_avatar_url'], :user_id => @user.id))
            flash[:success] = 'Your profile and photo was updated'
            redirect_to user_path(@user)
        else
          flash[:danger] = 'An error has occured, Please try again!'
          redirect_to edit_user_path(@user)
        end
      end
    end
  end
end

def avatar
  @user = User.find_by_uid(params[:id])
  authorize @user
  Album.find_by(user_id: @user.id).destroy
  # key = album.original_avatar_url.split('amazonaws.com/')[1]
  # S3_BUCKET.object(key).delete
  # album.destroy
  respond_to do |format|
    format.js
  end
end

def image
  @user = User.find_by_uid(params[:id])
  authorize @user
  Photo.find_by(user_id: @user.id).destroy
  # key = album.original_avatar_url.split('amazonaws.com/')[1]
  # S3_BUCKET.object(key).delete
  # album.destroy
  respond_to do |format|
    format.js
  end
end

def myposts
  if @user = User.find_by_uid(params[:id])
    authorize @user
    @posts = @user.posts.desc_order.paginate(page: params[:page])
  else
    redirect_to root_path
  end
end

def index
  @users = User.desc_order.paginate(page: params[:page])
  authorize User
  get_unpublished_count
  get_flaged_posts_count
  get_reported_users_count
end

def settings
 @user = current_user
end

def update_password
  @user = User.find_by_uid(current_user.id)
  if @user.update_with_password(user_params)
      # Sign in the user by passing validation in case their password changed
    sign_in @user, :bypass => true
    flash[:success] = "Password updated successfully!"
    redirect_to root_path
  else
    flash.now[:danger] = "An error has occured!"
    render "settings"
  end
end

def destroy
  @user = User.find_by_uid(params[:id])
  authorize @user
  if current_user.admin?
    if @user.destroy
      flash[:success] = "User deleted"
      redirect_to root_path
    else
      flash[:danger] = "An error has occured"
      redirect_to root_path
    end
  else
    current_password = ActionController::Base.helpers.sanitize(params[:user][:current_password])
    if @user.valid_password?(current_password) && @user.destroy
    flash[:success] = "User deleted"
    redirect_to root_path
    else
    flash[:danger] = "An error has occured"
    redirect_to root_path
    end
  end
end

def report
  @user = User.find_by_uid(params[:id])
  authorize @user
  if @user.reports(:reporter_id => current_user.id).size == 0
    @report = @user.reports.build(reporter_id: current_user.id)
  else
    flash[:danger] = "User already reported"
    redirect_to user_path(@user)
  end
end

def unreport
  @user = User.find_by_uid(params[:id])
  authorize @user
  @user.update_column(:reported, false) if @user.reported?
  flash[:success] = "User unreported"
  redirect_to reporting_user_path(@user)
end

def post_report
  @user = User.find_by_uid(params[:id])
  authorize @user
  if @user.reports(:reporter_id => current_user.id).size == 0
    @report = @user.reports.build(report_params)
    @report.reporter_id = current_user.id
    if @report.save
      @user.update_column(:reported, true) unless @user.reported?
      @user.update_column(:report_number, (@user.report_number + 1))
      flash[:success] = "Report Sent"
      redirect_to user_path(@user)
    else
      flash.now[:danger] = "An error has occured. Please try again"
      render "report"
    end
  end
end

def blocked
  @users = User.where(blocked: true).desc_order.paginate(page: params[:page])
  authorize User
  get_unpublished_count
  get_flaged_posts_count
  get_reported_users_count
  get_blocked_users_count
end


def block
  @user = User.find_by_uid(params[:id])
  authorize @user
  @user.update_column(:blocked, true) unless @user.blocked?
  @user.update_column(:reported, false) if @user.reported?
  flash[:success] = "User Blocked"
  redirect_to reporting_user_path(@user)
end

def unblock
  @user = User.find_by_uid(params[:id])
  authorize @user
  @user.update_column(:blocked, false) if @user.blocked?
  flash[:success] = "User unblocked"
  redirect_to reporting_user_path(@user)
end

def reported
  @users = User.where(reported: true).desc_report_order.paginate(page: params[:page])
  authorize User
  get_unpublished_count
  get_flaged_posts_count
  get_reported_users_count
end

def reporting
  @user = User.find_by_uid(params[:id])
  authorize @user
  @reported_messages = @user.reports
  @sent_messages = @user.sent_messages
  @album = Album.find_by(user_id: @user.id)
end

def searching_form
  authorize User
end

def search
  authorize User
  if !params[:q].blank?
    @user = User.find_by_email(ActionController::Base.helpers.sanitize(params[:q]))
  else
    redirect_to searching_form_users_path
  end
end

    private
      def edit_user_params
        params.require(:user).permit(:username, :date_of_birth, :description, albums_attributes: [:id, :user_id, :original_avatar_url], photos_attributes: [:id, :user_id, :original_image_url])
      end
      
      def user_params
        params.require(:user).permit(:current_password, :password, :password_confirmation)
      end
      
      def set_s3_direct_post
        @s3_direct_post = S3_BUCKET.presigned_post(key: "uploads/original/#{SecureRandom.uuid}/${filename}", success_action_status: '201', acl: 'public-read', content_length_range: 0..5242880 )
        @s3_direct_post.content_type('image/*')
      end
      
    def report_params
      params.require(:report).permit(:report_message, :verification)
    end
      

      # def deleted_params
      #   params.require(:user).permit(:current_password)
      # end

      # def create_album_params
      #   params.require(:user).permit(albums_attributes: [:id, :user_id, :avatar])
      # end
      
      # def correct_user
      #   @user = User.find(params[:id])
      #   redirect_to (root_url) unless (current_user == @user)
      # end

end
