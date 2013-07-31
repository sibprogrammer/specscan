class Admin::AdditionalUsersController < Admin::Base

  before_filter :set_selected_user, :only => [:show, :edit, :update, :lock, :unlock, :destroy]

  def index
    @columns = %w{ login name email }
    @columns << 'owner_id' if can? :manage, :all
    @sort_state = get_list_sort_state(@columns, :additional_users_list, :dir => 'asc', :field => 'login')
    @users = User.page(get_list_page).
      where('role = ?', User::ROLE_USER).
      order("#{@sort_state[:field]} #{@sort_state[:dir]}")
    @users = @users.where('owner_id = ?', current_user.id) unless can? :manage, :all
  end

  def new
    @user = User.new(:role => User::ROLE_USER)
    @user.login = "#{@current_user.login}-user"
  end

  def create
    @user = User.new(params[:user])
    @user.role = User::ROLE_USER
    @user.owner = current_user unless can? :manage, :all

    if @user.save
      action_log(:create_additional_user, :user => @user.login, :owner => @user.owner.login)
      redirect_to(admin_additional_users_path, :notice => t('admin.additional_users.create.user_created', :login => @user.login))
    else
      render :action => 'new'
    end
  end

  def show
  end

  def edit
  end

  def update
    if params[:user][:password].blank?
      params[:user].delete(:password)
      params[:user].delete(:password_confirmation)
    end

    params[:user].delete(:login)
    params[:user].delete(:role)
    params[:user].delete(:owner_id) unless can? :manage, :all

    if @user.update_attributes(params[:user])
      action_log(:update_additional_user, :user => @user.login, :owner => @user.owner.login)
      redirect_to(admin_additional_users_path, :notice => t('admin.additional_users.update.user_updated', :login => @user.login))
    else
      render :action => 'edit'
    end
  end

  def lock
    @user.lock
    action_log(:lock_additional_user, :user => @user.login, :owner => @user.owner.login)
    redirect_to(admin_additional_user_path(@user), :notice => t('admin.additional_users.lock.locked', :login => @user.login))
  end

  def unlock
    @user.unlock
    action_log(:unlock_additional_user, :user => @user.login, :owner => @user.owner.login)
    redirect_to(admin_additional_user_path(@user), :notice => t('admin.additional_users.unlock.unlocked', :login => @user.login))
  end

  def destroy
    @user.destroy
    action_log(:destroy_additional_user, :user => @user.login, :owner => @user.owner.login)
    redirect_to(admin_additional_users_path, :notice => t('admin.additional_users.destroy.user_deleted'))
  end

  private

    def set_selected_user
      @user = User.find(params[:id])
      authorize! :edit, @user
    end

end
