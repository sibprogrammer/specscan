class Admin::PlansController < Admin::Base

  before_filter :set_selected_plan, :only => [:show, :edit, :update, :destroy]

  def index
    @columns = %w{ name price billing_period }
    @sort_state = get_list_sort_state(@columns, :plans_list, :dir => 'asc', :field => 'name')
    @plans = Plan.page(get_list_page).order("#{@sort_state[:field]} #{@sort_state[:dir]}")
  end

  def show
  end

  def new
    @plan = Plan.new
  end

  def create
    @plan = Plan.new(params[:plan])

    if @plan.save
      action_log(:create_plan, :plan => @plan.name)
      redirect_to(admin_plans_path, :notice => t('admin.plans.create.plan_created', :name => @plan.name))
    else
      render :action => 'new'
    end
  end

  def edit
  end

  def update
    if @plan.update_attributes(params[:plan])
      action_log(:update_plan, :plan => @plan.name)
      redirect_to(admin_plans_path, :notice => t('admin.plans.update.plan_updated'))
    else
      render :action => 'edit'
    end
  end

  def destroy
    @plan.destroy
    action_log(:destroy_plan, :plan => @plan.name)
    redirect_to(admin_plans_path, :notice => t('admin.plans.destroy.plan_deleted'))
  end

  private

    def set_selected_plan
      @plan = Plan.find(params[:id])
      authorize! :manage, @plan
    end

end
