# Users Controller
#
# Provides a user/account management interface.
class UsersController < AuthorizedController
  # Scopes
  has_scope :tagged_with
  actions :index
  
  # Actions
  def update
    @user = User.find(params[:id])
    
    # Don't try to update password if not provided
    if params[:user][:password].blank?
      [:password, :password_confirmation, :current_password].collect{|p| params[:user].delete(p) }
    end

    update!
  end

  def unlock
    @user = resource
    @user.unlock_access!
    
    redirect_to users_path, :notice => t('crud.flash.unlocked', :user => @user.to_s)
  end

  def current
    redirect_to current_user
  end
end
