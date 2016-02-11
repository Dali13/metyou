class PostsController < ApplicationController
require 'auto_compeletion_cp_city'
before_action :authenticate_user!, only: [:new, :create, :index, :show]
# before_action :opposite_gender_users, only: [:index]

  def new
    @post = current_user.posts.build
    respond_to do |format|
      format.html
    end
  end
  
  def create
    @post = current_user.posts.build(post_params)
    if @post.save
      flash[:success] = "Post created"
      redirect_to @post
    else
      flash.now[:danger] = "An error has occured. Please try again"
      render new_post_path
    end
  end
  
  def show
    @post = Post.find(params[:id])
    if current_user.reply_posts.include?(@post)
      @message = nil
    else
      @message = current_user.sent_messages.build(reply_post_id: @post.id)
    end
  end
  

  
  
  def index
    case current_user.gender when "M"
      @posts = Post.includes(:user).where(:users => {:gender => "F"}).paginate(page: params[:page])
    else
      @posts = Post.includes(:user).where(:users => {:gender => "M"}).paginate(page: params[:page])
    end
  end
  
  def autocomplete
    postal_file = File.read("#{Rails.root}/public/postal_code_fr.json")
    postal_parse = JSON.parse(postal_file)
    @list = []
    if !(ActionController::Base.helpers.sanitize(params[:codePostal]).blank?)
      search_term = params[:codePostal]
      search = /\A#{search_term}/
          postal_parse["cp_autocomplete"].each do |f|
            if search.match("#{f['CP']}",0) && (@list.length < 9)
              selected = AutoCompletionCpCity.new
              selected.CodePostal = f['CP']
              selected.Ville = f['VILLE']
              @list << selected
            end
          end
    else
      search_term = ActionController::Base.helpers.sanitize(params[:ville])
      search = /\A#{Regexp.escape(search_term)}/i
      postal_parse["cp_autocomplete"].each do |f|
            if search.match("#{f['VILLE']}",0) && (@list.length < 9)
              selected = AutoCompletionCpCity.new
              selected.CodePostal = f['CP']
              selected.Ville = f['VILLE']
              @list << selected
            end
          end
    end
    
    respond_to do |format|
      format.json { 
        render json: @list
      }
    end
  end

  def send_message
  @message = current_user.sent_messages.build(message_params)
  @message.reply_post_id = params[:id]
    if @message.save
      flash[:success] = "Message Sent"
      redirect_to post_path(@message.reply_post)
    else
      flash.now[:danger] = "An error has occured. Please try again"
      render post_path(@message.reply_post)
    end
  end

   
    

    private

    def post_params
      params.require(:post).permit(:title, :city, :postal_code, :meeting_date, :description)
    end
    
    def message_params
      params.require(:message).permit(:content)
    end
    
end

