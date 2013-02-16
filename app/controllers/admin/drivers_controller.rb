class Admin::DriversController < Admin::Base

  before_filter :set_selected_driver, :only => [:show, :edit, :update, :destroy]
  before_filter :check_manage_permission, :only => [:new, :create, :destroy, :edit, :update]
  before_filter :check_edit_permission, :only => [:destroy, :edit, :update]

  def index
    @columns = %w{ name vehicle_id categories }
    @columns << 'owner_id' if can? :manage, :all
    @sort_state = get_list_sort_state(@columns, :drivers_list, :dir => 'asc', :field => 'name')
    owner = current_user.user? ? current_user.owner : current_user
    @drivers = can?(:manage, :all) ? Driver : owner.drivers
    @drivers = @drivers.page(get_list_page).order("#{@sort_state[:field]} #{@sort_state[:dir]}")
  end

  def show
  end

  def new
    @driver = Driver.new
  end

  def create
    @driver = Driver.new(params[:driver])
    @driver.owner = current_user unless can? :manage, :all

    if @driver.save
      redirect_to(admin_drivers_path, :notice => t('admin.drivers.create.driver_created', :name => @driver.name))
    else
      render :action => 'new'
    end
  end

  def edit
  end

  def update
    params[:driver].delete(:owner_id) unless can? :manage, :all

    if @driver.update_attributes(params[:driver])
      redirect_to(admin_drivers_path, :notice => t('admin.drivers.update.driver_updated'))
    else
      render :action => 'edit'
    end
  end

  def destroy
    @driver.destroy
    redirect_to(admin_drivers_path, :notice => t('admin.drivers.destroy.driver_deleted'))
  end

  private

    def set_selected_driver
      @driver = Driver.find(params[:id])
      authorize! :view, @driver
    end

    def check_manage_permission
      authorize! :manage, Driver
    end

    def check_edit_permission
      driver = Driver.find(params[:id])
      authorize! :edit, driver
    end

end
