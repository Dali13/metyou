class PostsController < ApplicationController

before_action :authenticate_user!, only: [:new, :create, :show, :index, :autocomplete, :search, :send_message, :edit, :update, :unpublished]
before_action :confirmed_user, only: [:new, :create, :send_message, :edit, :update]
before_action :get_count, only: [:unpublished]
before_action :admin_user, only: [:unpublished, :publish]

  def new
    @post = current_user.posts.build
    respond_to do |format|
      format.html
    end
  end
  
  def create
    @post = current_user.posts.build(post_params)
    @post.gender = current_user.gender
    if @post.save
      flash[:success] = "Post created"
      redirect_to @post
    else
      flash.now[:danger] = "An error has occured. Please try again"
      render new_post_path
    end
  end
  
  def show
    @post = Post.friendly.find(params[:id])
    authorize @post
    if current_user.reply_posts.include?(@post) || current_user.owner_of?(@post)
      @message = nil
    else
      @message = current_user.sent_messages.build(reply_post_id: @post.id)
    end
  end
  

  def index
    if current_user.admin?
      @posts = policy_scope(Post.desc_order.paginate(page: params[:page]))
      get_count
    else
      case current_user.gender when "M"
        @posts = policy_scope(Post.where(:gender => "F").desc_order.paginate(page: params[:page]))
      else
        @posts = policy_scope(Post.where(:gender => "M").desc_order.paginate(page: params[:page]))
      end
    end
  end
  
  def autocomplete
    require 'auto_compeletion_cp_city'
    if !ActionController::Base.helpers.sanitize(params[:codePostal]).blank?
      search_term = ActionController::Base.helpers.sanitize(params[:codePostal])
      range = $redis.zrange "postal:#{search_term}", 0, 3
      @list = []
        if !range.blank?
          case range.length
          when 1
            t = $redis.hmget 'postal-data', range[0]
          when 2
            t = $redis.hmget 'postal-data', range[0], range[1]
          when 3
            t = $redis.hmget 'postal-data', range[0], range[1], range[2]
          else
            t = $redis.hmget 'postal-data', range[0], range[1], range[2], range[3]
          end
          t.map! do |n|
            JSON.parse(n)
          end
          t.each do |m|
            break if m.blank?
            selected = AutoCompletionCpCity.new
            selected.CodePostal = m['CP']
            selected.Ville = m['VILLE']
            @list << selected
          end
        end
    else
        if !(ActionController::Base.helpers.sanitize(params[:ville]).blank?)
          search_term = ActionController::Base.helpers.sanitize(params[:ville]).parameterize.downcase
          range = $redis.zrange "city:#{search_term}", 0, 3
          @list = []
          if !range.blank?
            case range.length
            when 1
              t = $redis.hmget 'postal-data', range[0]
            when 2
              t = $redis.hmget 'postal-data', range[0], range[1]
            when 3
              t = $redis.hmget 'postal-data', range[0], range[1], range[2]
            else
              t = $redis.hmget 'postal-data', range[0], range[1], range[2], range[3]
            end
            t.map! do |n|
              JSON.parse(n)
            end
            t.each do |m|
              break if m.blank?
              selected = AutoCompletionCpCity.new
              selected.CodePostal = m['CP']
              selected.Ville = m['VILLE']
              @list << selected
            end
          end
        end
    end

    # ActiveSupport::Dependencies.remove_const(DATA)
    # $redis.get('postal')
    # require 'auto_compeletion_cp_city'
    # @list = []
    # if !(ActionController::Base.helpers.sanitize(params[:codePostal]).blank?)
    #   search_term = ActionController::Base.helpers.sanitize(params[:codePostal])
    #   search = /\A#{search_term}/
    #       DATA["cp_autocomplete"].each do |f|
    #         if search.match("#{f['CP']}",0) && (@list.length < 4)
    #           selected = AutoCompletionCpCity.new
    #           selected.CodePostal = f['CP']
    #           selected.Ville = f['VILLE']
    #           @list << selected
    #         end
    #       end
    # else
    #   if !(ActionController::Base.helpers.sanitize(params[:ville]).blank?)
    #   search_term = ActionController::Base.helpers.sanitize(params[:ville]).parameterize
    #   search = /\A#{Regexp.escape(search_term)}/i
    #   DATA["cp_autocomplete"].each do |f|
    #         if search.match("#{f['CITY_PAR']}",0) && (@list.length < 4) 
    #           selected = AutoCompletionCpCity.new
    #           selected.CodePostal = f['CP']
    #           selected.Ville = f['VILLE']
    #           @list << selected
    #         end
    #   end
    #   end
    # end
    
    respond_to do |format|
      format.json { 
        render json: @list
      }
    end
  end
  
  def search
    if params[:q].blank?
      redirect_to root_path
    else
      query = ActionController::Base.helpers.sanitize(params[:q])
      case current_user.gender when "M"
        @posts = Post.male_search(query).records.paginate(page: params[:page])
      else
        @posts = Post.female_search(query).records.paginate(page: params[:page])
      end
    end
  end

  def send_message
  @post = Post.friendly.find(params[:id])
  authorize @post
  if !current_user.reply_posts.include?(@post)
    @message = current_user.sent_messages.build(message_params)
    @message.reply_post_id = @post.id
      if @message.save
        MessageMailer.delay.message_email(@message.id)
        current_user.follow(@post.user) unless current_user.following?(@post.user)
        flash[:success] = "Message Sent"
        redirect_to post_path(@message.reply_post)
      else
        flash.now[:danger] = "An error has occured. Please try again"
        render post_path(@message.reply_post)
      end
  end
  end
  
  
  def edit
    @post = Post.friendly.find(params[:id])
    authorize @post
  end

  def update
    @post = Post.friendly.find(params[:id])
    authorize @post
    if current_user.admin?
      if @post.update_attributes(update_params)
        flash[:success] = "Post updated"
        redirect_to @post
      else
        render 'edit'
      end
    else
      if (@post.update_attributes(update_params) && @post.update_attributes(:published => false))
        flash[:success] = "Post updated"
        redirect_to @post
      else
        render 'edit'
      end
    end
  end
  
  def unpublished
    @posts = policy_scope(Post.unpublished.asc_order.paginate(page: params[:page]))
  end 
  
  def publish
    @post = Post.friendly.find(params[:id])
    
    if !@post.published? && (ActionController::Base.helpers.sanitize(params[:published]) == "protect")
      @post.update_attributes(:published => true)
      redirect_to unpublished_posts_path
    else
      flash[:danger] = "Already published"
      redirect_to root_path
    end
  end
  
  def destroy
    @post = Post.friendly.find(params[:id])
    authorize @post
    if @post.destroy
      flash[:success] = "Post deleted"
      redirect_to root_path
    end
  end
    
    
    
    

    private

    def post_params
      params.require(:post).permit(:title, :city, :postal_code, :meeting_date, :description)
    end
    
    def update_params
      params.require(:post).permit(policy(@post).post_permitted_attributes)
    end
    
    def message_params
      params.require(:message).permit(:content)
    end
    

    
    
    
end

