class ApiController < ApplicationController

  before_filter :get_application, :get_version, :get_package_name, :is_valid

  def get_application
    if Application.exists? params[:application_id]
      @application = Application.find(params[:application_id])
    else
      render_result "application_not_existed", nil
    end
  end

  def get_version
    @current_version = @application.version.where(:version_code => params[:current_version]).first
    @last_version = @application.version.last
    render_result "current_version_not_existed", nil if @current_version.nil?
  end

  def get_package_name
    begin
      @package_name = Base64.urlsafe_decode64(params[:package_name])
    rescue
      render_result "package_name_not_match", nil and return
    end
  end

  def is_valid
    if @package_name != @application.package_name
      render_result "package_name_not_match", nil and return
    end
    unless @last_version.version_code > @current_version.version_code
      render_result "no_update", nil
    end
  end

  def update
    json = @last_version.to_json_hash
    json.merge!({"apk_patch_size" => patch_size})
    render_result "has_update", json
  end

  def download
    path = Differ::MakeVersionPatch.get_patch_file_path(@current_version, @last_version)
    send_file path
  end

  def render_result(message, information)
    render :json => {"message" => message, "information" => information}
  end

  def patch_size
    Differ::MakeVersionPatch.get_patch_size(@current_version, @last_version)
  end

end
