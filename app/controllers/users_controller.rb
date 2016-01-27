class UsersController < ApplicationController
  before_action :authenticate_user!, only: [:show]
  before_action :correct_user, only: [:show, :edit, :update]

def show
end

def edit
end

def update
end

    private
      def edit_user_params
        params.require(:user).permit(:username, :date_of_birth, :description)
      end
      
      def correct_user
        @user = User.find(params[:id])
        redirect_to (root_url) unless (current_user == @user)
      end

end
