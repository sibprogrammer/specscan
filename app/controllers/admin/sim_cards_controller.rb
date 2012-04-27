class Admin::SimCardsController < Admin::Base

  before_filter :check_manage_permission
  before_filter :set_selected_sim_card, :only => [:show, :edit, :update, :check_balance]

  def index
    @columns = %w{ phone balance created_at updated_at }
    @sort_state = get_list_sort_state(@columns, :sim_cards_list, :dir => 'asc', :field => 'balance')
    @sim_cards = SimCard.page(get_list_page).
      order("#{@sort_state[:field]} #{@sort_state[:dir]}")
  end

  def show
  end

  def new
    @sim_card = SimCard.new
  end

  def create
    @sim_card = SimCard.new(params[:sim_card])

    if @sim_card.save
      redirect_to(admin_sim_cards_path, :notice => t('admin.sim_cards.create.sim_card_created'))
    else
      render :action => 'new'
    end
  end

  def edit
  end

  def update
    params[:sim_card].delete(:helper_password) if params[:sim_card][:helper_password].blank?

    if @sim_card.update_attributes(params[:sim_card])
      redirect_to(admin_sim_cards_path, :notice => t('admin.sim_cards.update.sim_card_updated', :phone => @sim_card.phone))
    else
      render :action => 'edit'
    end
  end

  def check_balance
    @sim_card.update_balance
    redirect_to(admin_sim_card_path(@sim_card), :notice => t('admin.sim_cards.check_balance.checked', :phone => @sim_card.phone))
  end

  private

    def check_manage_permission
      authorize! :manage, SimCard
    end

    def set_selected_sim_card
      @sim_card = SimCard.find(params[:id])
      authorize! :edit, @sim_card
    end

end
