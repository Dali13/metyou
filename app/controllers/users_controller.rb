class UsersController < ApplicationController
  before_action :authenticate_user!, only: [:show]
  before_action :correct_user, only: [:show, :edit, :update]

def show
  @album = Album.find_by(user_id: current_user[:id])
  @user = User.find(params[:id])
end

def edit
  @album = current_user.albums.build
  
  if current_user.albums.count > 0
  album_existant = Album.find_by(user_id: current_user[:id])
  @avatar = album_existant.avatar
  else
  @avatr = nil
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
    if (current_user.update_attributes(edit_user_params) && current_user.albums.create(:avatar => params[:albums]['avatar'], :user_id => current_user.id))
        flash[:success] = 'Your profile and avatar was updated'
        redirect_to current_user
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
