class Admin::ToolsController < Admin::Base

  before_filter :check_manage_permission

  def index
  end

  def packets_monitor
    if request.post?
      conditions = {}
      conditions[:imei] = params[:imei] if params.key?(:imei) and !params[:imei].blank?
      @way_points = WayPoint.where(conditions).sort(:timestamp.desc).limit(10)
      @tags_filter = (params.key?(:tags_filter) ? params[:tags_filter] : '').split
    end
  end

  private

    def check_manage_permission
      current_user.admin?
    end

end
