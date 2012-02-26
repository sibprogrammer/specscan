class Admin::UsersController < Admin::Base

  menu_section :users
  before_filter :check_manage_permission, :except => [:profile, :update]
  before_filter :set_selected_user, :only => [:show, :edit, :update]

  def index
    @users = User.all(:order => 'created_at DESC')
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

  private

    def check_manage_permission
      authorize! :manage, User
    end

    def set_selected_user
      @user = User.find(params[:id])
    end

end
