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

  def daemons_status
    config_file_name = Rails.root + 'config/daemons.yml'
    return unless File.exists? config_file_name
    @daemons = YAML.load_file(config_file_name)
    @daemons.each do |daemon|
      daemon['status'] = process_alive?(File.read(daemon['pid_file']).to_i)
    end
  end

  private

    def check_manage_permission
      current_user.admin?
    end

    def process_alive?(pid)
      begin
        Process.getpgid(pid)
        true
      rescue Errno::ESRCH
        false
      end
    end

end
