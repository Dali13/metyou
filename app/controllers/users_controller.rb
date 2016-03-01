class UsersController < ApplicationController
  before_action :authenticate_user!
  #before_action :admin_user, only: [:index]
  #before_action :correct_user, only: [:show, :edit, :update]

def show
  if @user = User.find_by_uid(params[:id])
    @album = Album.find_by(user_id: @user.id)
  else
    redirect_to root_url
  end
end

def edit
  if @user = User.find_by_uid(params[:id])
    authorize @user
    @album = @user.albums.build
    if @user.albums.count > 0
    @avatar = Album.find_by(user_id: @user.id).avatar
    else
    @avatr = nil
    end
  else
    redirect_to root_url    
  end
end

def update
  @user = User.find_by_uid(params[:id])
  authorize @user
  if !params.has_key?(:albums)
    if @user.update_attributes(edit_user_params)
      flash[:success] = 'Your profile was updated'
      redirect_to user_path(@user)
    else
      flash[:danger] = 'An error has occured, Please try again!'
      redirect_to edit_user_path(@user)
    end
  else
    if (@user.update_attributes(edit_user_params) && @user.albums.create(:avatar => params[:albums]['avatar'], :user_id => @user.id))
        flash[:success] = 'Your profile and avatar was updated'
        redirect_to user_path(@user)
    else
      flash[:danger] = 'An error has occured, Please try again!'
      redirect_to edit_user_path(@user)
    end
  end
end

def avatar
  @user = User.find_by_uid(params[:id])
  authorize @user
  Album.find_by(user_id: @user.id).destroy
  respond_to do |format|
    format.js
  end
end

def myposts
  if @user = User.find_by_uid(params[:id])
    authorize @user
    @posts = @user.posts.paginate(page: params[:page])
  else
    redirect_to root_path
  end
end

def index
  @users = User.paginate(page: params[:page])
  authorize User
  get_count
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
    render settings_users_path
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
      

    private
      def edit_user_params
        params.require(:user).permit(:username, :date_of_birth, :description, albums_attributes: [:id, :user_id, :avatar])
      end
      
      def user_params
        params.require(:user).permit(:current_password, :password, :password_confirmation)
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
