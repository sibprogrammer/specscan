class Admin::UsersController < Admin::Base

  menu_section :users

  def index
    @users = User.all

    @sidebar_actions = [{
      :title => t('admin.users.index.action.add_user'),
      :link => new_admin_user_path
    }]
  end

  def new
    @user = User.new
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
    @user = User.find(params[:id])
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])

    if params[:user][:password].blank?
      params[:user].delete(:password)
      params[:user].delete(:password_confirmation)
    end

    if @user.update_attributes(params[:user])
      redirect_to(admin_users_path, :notice => t('admin.users.update.user_updated', :login => @user.login))
    else
      render :action => 'edit'
    end
  end

end
