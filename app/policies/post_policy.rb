class PostPolicy < ApplicationPolicy
  
  class Scope < Scope
    def resolve
      if user.admin?
        scope.all
      else
        scope.where(published: true)
      end
    end
  end
  
  attr_reader :user, :post

  def initialize(user, post)
    @user = user
    @post = post
  end

  def new?
    !user.admin?
  end
  
  def create?
    !user.admin?
  end
  
  
  def show?
   user.admin? || user.owner_of?(post)  || ( post.published? && post.gender != user.gender ) 
  end
  
  def send_message?
    user.superadmin? or ((user.gender != post.gender) && (!user.owner_of?(post)) && !user.admin?)
  end
  
  def edit?
    user.owner_of?(post) || user.admin?
  end
  
  def update?
    user.owner_of?(post) || user.admin?
  end
  
  def destroy?
    user.owner_of?(post) || user.admin?
  end
  
  def flag?
    (!user.owner_of?(post) && user.gender != post.gender)
  end
  
  def post_flag?
    (!user.owner_of?(post) && user.gender != post.gender)
  end
  
  def unpublished?
    user.admin?
  end
  
  def publish?
    user.admin?
  end
  
  def flaged?
    user.admin?
  end
  
  def unflag?
    user.admin?
  end
  
  def reporting?
    user.admin?
  end

  
  def post_permitted_attributes
    if user.admin?
      [:title, :city, :postal_code, :meeting_date, :description, :lat, :lon, :published]
    else
      [:title, :city, :postal_code, :meeting_date, :description, :lat, :lon]
    end
  end
  
  
end