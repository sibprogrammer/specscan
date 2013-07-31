class Admin::UsersController < Admin::Base

  before_filter :check_manage_permission, :except => [:profile, :update, :destroy, :impersonate, :impersonation_logout]
  before_filter :set_selected_user, :only => [:show, :edit, :update, :lock, :unlock, :destroy, :impersonate, :update_balance]

  def index
    @columns = %w{ login name balance vehicles_total created_at }
    @sort_state = get_list_sort_state(@columns, :users_list, :dir => 'desc', :field => 'created_at')
    @users = User.page(get_list_page).
      joins("LEFT JOIN vehicles ON users.id = vehicles.user_id").
      select("users.*, COUNT(vehicles.user_id) AS vehicles_total").
      where('role IN (?)', [User::ROLE_CLIENT, User::ROLE_ADMIN]).
      group("users.id").
      order("#{@sort_state[:field]} #{@sort_state[:dir]}")
  end

  def new
    @user = User.new(:role => User::ROLE_CLIENT)
  end

  def create
    @user = User.new(params[:user])

    if @user.save
      action_log(:create_user, :login => @user.login)
      redirect_to(admin_users_path, :notice => t('admin.users.create.user_created', :login => @user.login))
    else
      render :action => 'new'
    end
  end

  def show
    @columns = %w{ name reg_number imei owner created_at }
    @sort_state = get_list_sort_state(@columns, :user_vehicles_admin_list, :dir => 'desc', :field => 'created_at')
    order = "#{@sort_state[:field]} #{@sort_state[:dir]}"
    @vehicles = @user.vehicles.reorder(order) if @user.vehicles.length > 0
  end

  def edit
  end

  def profile
    @user = current_user
    @profile = true
  end

  def update
    authorize! :manage, User if @user.id != current_user.id

    if params[:user][:password].blank?
      params[:user].delete(:password)
      params[:user].delete(:password_confirmation)
    end

    params[:user].delete(:login)
    params[:user].delete(:role) unless can? :manage, @user

    if @user.update_attributes(params[:user])
      action_log(:update_user, :login => @user.login)
      if params.key?(:profile)
        redirect_to(admin_profile_path, :notice => t('admin.profile.updated'))
      else
        redirect_to(admin_users_path, :notice => t('admin.users.update.user_updated', :login => @user.login))
      end
    else
      render :action => 'edit'
    end
  end

  def lock
    @user.lock
    action_log(:lock_user, :login => @user.login)
    redirect_to(admin_user_path(@user), :notice => t('admin.users.lock.locked', :login => @user.login))
  end

  def unlock
    @user.unlock
    action_log(:unlock_user, :login => @user.login)
    redirect_to(admin_user_path(@user), :notice => t('admin.users.unlock.unlocked', :login => @user.login))
  end

  def destroy
    @user.destroy
    action_log(:destroy_user, :login => @user.login)
    redirect_to(admin_users_path, :notice => t('admin.users.destroy.user_deleted'))
  end

  def impersonate
    redirect_to(root_path) unless session[:impersonated_user_id] or authorize! :manage, User
    session[:impersonated_user_id] = current_user.id unless session[:impersonated_user_id]
    relogin(@user)
  end

  def impersonation_logout
    user = User.find(session[:impersonated_user_id])
    session.delete(:impersonated_user_id)
    relogin(user)
  end

  def update_balance
    if request.post?
      amount = params[:amount].to_i
      @user.balance += amount
      @user.save
      action_log(:update_balance, :login => @user.login, :amount => amount)
      redirect_to(admin_user_path(@user), :notice => t('admin.users.update_balance.updated', :login => @user.login, :amount => amount))
    end
  end

  private

    def check_manage_permission
      authorize! :manage, User
    end

    def set_selected_user
      @user = User.find(params[:id])
    end

    def relogin(user)
      sign_out :user
      sign_in user
      redirect_to root_path
    end

end
