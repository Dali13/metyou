class UsersController < ApplicationController
  before_action :authenticate_user!, only: [:show]
  before_action :correct_user, only: [:show, :edit, :update]

def show
  @album = Album.find_by(user_id: current_user[:id])
  @user = User.find(params[:id])
end

def edit
  @album = current_user.albums.build
  
  @album_existant = Album.find_by(user_id: current_user[:id])
  
  if @album_existant.blank? || @album_existant.avatar.blank?
    @avatar = nil
  else
    @avatar = @album_existant.avatar
  end
end

def update
  if !params.has_key?(:albums)
    if current_user.update_attributes(edit_user_params)
      flash[:success] = 'Your profile was updated'
      redirect_to current_user
    else
      flash[:danger] = 'An error has occured, Please try again!'
      redirect_to edit_user_path(current_user)
    end
  else
    if current_user.update_attributes(edit_user_params)
      @album = current_user.albums.create(:avatar => params[:albums]['avatar'], :user_id => current_user.id)
      if @album.errors.blank?
        flash[:success] = 'Your profile and avatar was updated'
        redirect_to current_user
      else
        flash[:danger] = 'Too many avatars!'
        redirect_to edit_user_path(current_user)
      end
    else
      flash[:danger] = 'An error has occured, Please try again!'
      redirect_to edit_user_path(current_user)
    end
  end
end

def avatar
  Album.find_by(user_id: params[:id]).destroy
  respond_to do |format|
    format.js
  end
end
      

    private
      def edit_user_params
        params.require(:user).permit(:username, :date_of_birth, :description, albums_attributes: [:id, :user_id, :avatar])
      end
      
      # def create_album_params
      #   params.require(:user).permit(albums_attributes: [:id, :user_id, :avatar])
      # end
      
      def correct_user
        @user = User.find(params[:id])
        redirect_to (root_url) unless (current_user == @user)
      end

end
