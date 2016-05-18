class PostsController < ApplicationController

before_action :authenticate_user!
before_action :confirmed_user, only: [:new, :create, :send_message, :edit, :update, :flag, :post_flag]
# before_action :get_unpublished_count, only: [:unpublished]
# before_action :get_flaged_posts_count, only: [:unpublished]
# before_action :get_reported_users_count, only: [:unpublished]
#before_action :admin_user, only: [:unpublished, :publish, :flaged]
invisible_captcha only: [:send_message, :create, :post_flag], honeypot: :verification

  def new
    @post = current_user.posts.build
    authorize @post
    respond_to do |format|
      format.html
    end
  end
  
  def create
    @post = current_user.posts.build(post_params)
    authorize @post
    @post.gender = current_user.gender
    if @post.save
      flash[:success] = "Post created"
      redirect_to @post
    else
      flash.now[:danger] = "An error has occured. Please try again"
      render "new"
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
      get_unpublished_count
      get_flaged_posts_count
      get_reported_users_count
    else
      case current_user.gender when "M"
        @posts = policy_scope(Post.where(:gender => "F").desc_order.paginate(page: params[:page]))
      else
        @posts = policy_scope(Post.where(:gender => "M").desc_order.paginate(page: params[:page]))
      end
    end
  end
  
  def autocomplete
    # if !($redis.try(:any?))
    # (JSON.parse(File.read("#{Rails.root}/public/03V16_third.json")))["cp_autocomplete"].each.with_index(1) do |f, index|
    #   $redis.hset 'postal-data', index.to_s, f.to_json
    # end

    # (JSON.parse(File.read("#{Rails.root}/public/03V16_third.json")))["cp_autocomplete"].each.with_index(1) do |f, index|
    #   (2..4).each do |n|
    #     prefix = (f['CP'][0..n]).to_s
    #     $redis.zadd("postal:#{prefix}", [0, index.to_s])
    #   end
    # end

    # # (JSON.parse(File.read("#{Rails.root}/public/03V16_third.json")))["cp_autocomplete"].each do |f|
    # #   f["CITY_PAR"] = f['VILLE'].parameterize
    # # end

    # (JSON.parse(File.read("#{Rails.root}/public/03V16_third.json")))["cp_autocomplete"].each.with_index(1) do |f, index|
    #   (2..(((f['VILLE'].parameterize).length)-1)).each do |n|
    #     prefix = ((f['VILLE'].parameterize)[0..n]).to_s.downcase
    #     $redis.zadd("city:#{prefix}", [0, index.to_s])
    #   end
    # end
    
    # end
    require 'auto_compeletion_cp_city'
    if !ActionController::Base.helpers.sanitize(params[:codePostal]).blank?
      # search_term = ActionController::Base.helpers.sanitize(params[:codePostal])
      range = $redis.zrange "postal:#{ActionController::Base.helpers.sanitize(params[:codePostal])}", 0, 3
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
            selected.Lat = m['LATITUDE']
            selected.Lon = m['LONGITUDE']
            @list << selected
          end
        end
    else
        if !(ActionController::Base.helpers.sanitize(params[:ville]).blank?)
          # search_term = ActionController::Base.helpers.sanitize(params[:ville]).parameterize.downcase
          range = $redis.zrange "city:#{ActionController::Base.helpers.sanitize(params[:ville]).parameterize.downcase}", 0, 3
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
              selected.Lat = m['LATITUDE']
              selected.Lon = m['LONGITUDE']
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
    if params[:q].blank? && params[:postal].blank?
      redirect_to root_path
    else
      if params[:postal].blank?
        # query = ActionController::Base.helpers.sanitize(params[:q])
        if current_user.admin?
          @posts = Post.admin_search(ActionController::Base.helpers.sanitize(params[:q])).records.paginate(page: params[:page])
        else
          case current_user.gender when "M"
            @posts = Post.male_search(ActionController::Base.helpers.sanitize(params[:q])).records.paginate(page: params[:page])
          else
            @posts = Post.female_search(ActionController::Base.helpers.sanitize(params[:q])).records.paginate(page: params[:page])
          end
        end
      else
        if params[:q].blank?
          if (params[:postal].length == 5) && (!params[:maxlat].blank?) && (!params[:minlon].blank?) && (!params[:minlat].blank?) && (!params[:maxlon].blank?)
            # maxlat = ActionController::Base.helpers.sanitize(params[:maxlat])
            # minlon = ActionController::Base.helpers.sanitize(params[:minlon])
            # minlat = ActionController::Base.helpers.sanitize(params[:minlat])
            # maxlon = ActionController::Base.helpers.sanitize(params[:maxlon])
            if current_user.admin?
              @posts = Post.geo_only_admin_search(ActionController::Base.helpers.sanitize(params[:maxlat]), ActionController::Base.helpers.sanitize(params[:minlon]), ActionController::Base.helpers.sanitize(params[:minlat]), ActionController::Base.helpers.sanitize(params[:maxlon])).records.paginate(page: params[:page])
            else
              case current_user.gender when "M"
                @posts = Post.geo_only_male_search(ActionController::Base.helpers.sanitize(params[:maxlat]), ActionController::Base.helpers.sanitize(params[:minlon]), ActionController::Base.helpers.sanitize(params[:minlat]), ActionController::Base.helpers.sanitize(params[:maxlon])).records.paginate(page: params[:page])
              else
                @posts = Post.geo_only_female_search(ActionController::Base.helpers.sanitize(params[:maxlat]), ActionController::Base.helpers.sanitize(params[:minlon]), ActionController::Base.helpers.sanitize(params[:minlat]), ActionController::Base.helpers.sanitize(params[:maxlon])).records.paginate(page: params[:page])
              end
            end
          end
        else
          if (params[:postal].length == 5) && (!params[:maxlat].blank?) && (!params[:minlon].blank?) && (!params[:minlat].blank?) && (!params[:maxlon].blank?)
            # query = ActionController::Base.helpers.sanitize(params[:q])
            # maxlat = ActionController::Base.helpers.sanitize(params[:maxlat])
            # minlon = ActionController::Base.helpers.sanitize(params[:minlon])
            # minlat = ActionController::Base.helpers.sanitize(params[:minlat])
            # maxlon = ActionController::Base.helpers.sanitize(params[:maxlon])
            if current_user.admin?
              @posts = Post.geo_admin_search(ActionController::Base.helpers.sanitize(params[:q]), ActionController::Base.helpers.sanitize(params[:maxlat]), ActionController::Base.helpers.sanitize(params[:minlon]), ActionController::Base.helpers.sanitize(params[:minlat]), ActionController::Base.helpers.sanitize(params[:maxlon])).records.paginate(page: params[:page])
            else
              case current_user.gender when "M"
                @posts = Post.geo_male_search(ActionController::Base.helpers.sanitize(params[:q]), ActionController::Base.helpers.sanitize(params[:maxlat]), ActionController::Base.helpers.sanitize(params[:minlon]), ActionController::Base.helpers.sanitize(params[:minlat]), ActionController::Base.helpers.sanitize(params[:maxlon])).records.paginate(page: params[:page])
              else
                @posts = Post.geo_female_search(ActionController::Base.helpers.sanitize(params[:q]), ActionController::Base.helpers.sanitize(params[:maxlat]), ActionController::Base.helpers.sanitize(params[:minlon]), ActionController::Base.helpers.sanitize(params[:minlat]), ActionController::Base.helpers.sanitize(params[:maxlon])).records.paginate(page: params[:page])
              end
            end
          end
        end
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
        render "show"
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
    authorize @posts
    get_unpublished_count
    get_flaged_posts_count
    get_reported_users_count
  end 
  
  def publish
    @post = Post.friendly.find(params[:id])
    authorize @post
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
    
  def flag
    @post = Post.friendly.find(params[:id])
    authorize @post
    if @post.flags(:flager_id => current_user.id).size == 0
      @flag = @post.flags.build(flager_id: current_user.id)
    else
      flash[:danger] = "Post already reported"
      redirect_to post_path(@post)
    end
  end
  
  def unflag
    @post = Post.friendly.find(params[:id])
    authorize @post
    @post.update_column(:flaged, false) if @post.flaged?
    flash[:success] = "Post unflaged"
    redirect_to reporting_post_path(@post)
  end

  def post_flag
    @post = Post.friendly.find(params[:id])
    authorize @post
    if @post.flags(:flager_id => current_user.id).size == 0
      @flag = @post.flags.build(flag_params)
      @flag.flager_id = current_user.id
      if @flag.save
        @post.update_column(:flaged, true) unless @post.flaged?
        @post.update_column(:flag_number, (@post.flag_number + 1))
        flash[:success] = "Report Sent"
        redirect_to post_path(@post)
      else
        flash.now[:danger] = "An error has occured. Please try again"
        render "flag"
      end
    end
  end  
  
  def flaged
    @posts = Post.where(flaged: true).desc_flag_order.paginate(page: params[:page])
    authorize @posts
    get_unpublished_count
    get_flaged_posts_count
    get_reported_users_count
  end
  
  def reporting
    @post = Post.friendly.find(params[:id])
    authorize @post
    @flags = @post.flags
  end
    

    private

    def post_params
      params.require(:post).permit(:title, :city, :postal_code, :meeting_date, :description, :lat, :lon, :verification)
    end
    
    def update_params
      params.require(:post).permit(policy(@post).post_permitted_attributes)
    end
    
    def message_params
      params.require(:message).permit(:content, :verification)
    end
    
    def flag_params
      params.require(:flag).permit(:flag_message, :verification)
    end

    
    
    
end

