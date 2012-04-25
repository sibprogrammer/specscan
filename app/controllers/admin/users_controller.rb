class Admin::UsersController < Admin::Base

  before_filter :check_manage_permission, :except => [:profile, :update]
  before_filter :set_selected_user, :only => [:show, :edit, :update, :lock, :unlock]

  def index
    @columns = %w{ login name email vehicles_total created_at }
    @sort_state = get_list_sort_state(@columns, :users_list, :dir => 'desc', :field => 'created_at')
    @users = User.page(get_list_page).
      joins("LEFT JOIN vehicles ON users.id = vehicles.user_id").
      select("users.*, COUNT(vehicles.user_id) AS vehicles_total").
      group("users.id").
      order("#{@sort_state[:field]} #{@sort_state[:dir]}")
  end

  def new
    @user = User.new(:role => User::ROLE_CLIENT)
  end

  def create
    @user = User.new(params[:user])

    if @user.save
      redirect_to(admin_users_path, :notice => t('admin.users.create.user_created', :login => @user.login))
    else
      render :action => 'new'
    end
  end

  def show
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
    params[:user].delete(:role_id) unless can? :manage, @user

    if @user.update_attributes(params[:user])
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
    redirect_to(admin_user_path(@user), :notice => t('admin.users.lock.locked', :login => @user.login))
  end

  def unlock
    @user.unlock
    redirect_to(admin_user_path(@user), :notice => t('admin.users.unlock.unlocked', :login => @user.login))
  end

  private

    def check_manage_permission
      authorize! :manage, User
    end

    def set_selected_user
      @user = User.find(params[:id])
    end

end
