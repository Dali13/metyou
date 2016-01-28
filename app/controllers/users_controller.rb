class UsersController < ApplicationController
  before_action :authenticate_user!, only: [:show]
  before_action :correct_user, only: [:show, :edit, :update]

def show
  @album = Album.find_by(user_id: current_user[:id])
end

def edit
  @album = current_user.albums.build
end

def update
  if current_user.update_attributes(edit_user_params)
    @album = current_user.albums.create!(:avatar => params[:albums]['avatar'], :user_id => current_user.id)
    flash[:success] = 'Your profile was updated'
    redirect_to current_user
  else
    flash.now[:danger] = 'An error has occured, Please try again!'
    render edit_user_path
  end
end

    private
      def edit_user_params
        params.require(:user).permit(:username, :date_of_birth, :description)
      end
      
      def create_album_params
        params.require(:user).permit(albums_attributes: [:id, :user_id, :avatar])
      end
      
      def correct_user
        @user = User.find(params[:id])
        redirect_to (root_url) unless (current_user == @user)
      end

end
