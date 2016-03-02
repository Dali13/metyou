class UserPolicy
  attr_reader :current_user, :model

  def initialize(current_user, model)
    @current_user = current_user
    @user = model
  end

  def index?
    @current_user.admin?
  end

  def edit?
    @current_user.admin? or @current_user == @user
  end

  def update?
    @current_user.admin? or @current_user == @user
  end
  
  def avatar?
    @current_user.admin? or @current_user == @user
  end

  def myposts?
    @current_user.admin? or @current_user == @user
  end
  
  # def settings?
  #   @current_user == @user
  # end
    
  def destroy?
    (@current_user.admin? && @user != @current_user) || (!@current_user.admin? && @user == @current_user)
  end

end