class UserPolicy
  attr_reader :current_user, :model

  def initialize(current_user, model)
    @current_user = current_user
    @user = model
  end

  def index?
    @current_user.superadmin?
  end
  
  def show?
    @current_user.admin? or @current_user == @user or @user.following?(@current_user)
  end
  
  def report?
   (@user.following?(@current_user) && @current_user != @user)
  end
  
  def unreport?
    @current_user.admin?
  end
  
  def post_report?
   (@user.following?(@current_user) && @current_user != @user)
  end
  
  def reporting?
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
  
  def image?
    @current_user.admin? or @current_user == @user
  end

  def myposts?
    @current_user.admin? or @current_user == @user
  end
  
  # def settings?
  #   @current_user == @user
  # end
    
  def destroy?
    (@current_user.admin? && !@user.admin?) || (!@current_user.admin? && @user == @current_user) || (@current_user.superadmin? && @user != @current_user)
  end
  
  def blocked?
    @current_user.admin?
  end
  
  def block?
    (@current_user.admin? && !@user.admin?) || (@current_user.superadmin? && @user != @current_user)
  end
  
  def unblock?
    (@current_user.admin? && !@user.admin?) || (@current_user.superadmin? && @user != @current_user)
  end
  
  def reported?
    @current_user.admin?
  end
  
  def searching_form?
    @current_user.admin?
  end
  
  def search?
    @current_user.admin?
  end

end