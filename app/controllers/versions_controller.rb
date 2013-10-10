class VersionsController < ApplicationController
  
  before_filter :authenticate_user!, :get_appliction, :is_has_application_ability
  before_filter :get_version,:is_has_version_ability, :except => [:index,:new,:create]
  before_filter :is_current_version_equal_last_version, :only => [:edit, :update, :destroy]
  before_filter :apk_method_chain, :only => [:create,:update]

  def get_appliction
    if Application.exists?(params[:application_id])
      @application = Application.find(params[:application_id])
    else
      flash[:notice] = t("version.not_exists_version") and redirect_to root_url
    end
  end

  def get_version
    if Version.exists?(params[:id])
      @version = @application.version.find(params[:id])
    else
      flash[:notice] = t("version.not_exists_version") and redirect_to root_url
    end
  end

  def is_has_application_ability
    unless @application.user == current_user
      flash[:notice] = t("version.not_current_user_own") and redirect_to root_url
    end
  end

  def is_has_version_ability
    unless @version.user == current_user
      flash[:notice] = t("version.not_current_user_own") and redirect_to root_url
    end
  end

  def is_current_version_equal_last_version
    if @version != @application.version.last
      flash[:notice] = t("version.can_not_edit_not_last_version") and redirect_to root_url
    end
  end

  def apk_method_chain
    return if params[:version][:apk].nil?
    get_apk_manifest
    is_version_all_right
    init_version
  end

  def get_apk_manifest
    begin
      file = params[:version][:apk]
      apk = Android::Apk.new(file.path)
      @manifest = apk.manifest
    rescue Android::NotApkFileError
      flash[:notice] = t("activerecord.errors.models.version.attributes.apk_file_name.invalid") 
      redirect_to new_application_version_path(@application)
    end
  end

  def is_version_all_right
    @version = Version.new(params[:version]) if action_name == "create"
    if @manifest.version_code <= current_max_version_code
      flash[:notice] = t("version.not_greater_than_the_newest_version") 
    end
    if @manifest.package_name != @application.package_name
      flash[:notice] = t("version.not_match_application_package_name") 
    end
    render action: "new" unless flash[:notice].nil?
  end

  def init_version
    @version.user = current_user
    @version.application  = @application
    @version.version_code = @manifest.version_code
    @version.version_name = @manifest.version_name
  end

  def current_max_version_code
    current_max_version_code = @application.version.maximum(:version_code)
    current_max_version_code ||= 0
    current_max_version_code
  end

  def make_patch
    begin
      @need_path_version = @application.version[0..@application.version.count-2]
      Differ::MakeVersionPatch.patch @need_path_version, @version
    rescue
      flash[:notice]  = t("differ.error")
    end
  end

  def index
    @versions = @application.version
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @versions }
    end
  end

  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @version }
    end
  end

  def new
    @version = Version.new
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @version }
    end
  end

  def edit

  end

  def create
    respond_to do |format|
      if @version.save
        make_patch
        format.html { redirect_to application_version_url(@application,@version), notice: 'Version was successfully created.' }
        format.json { render json: @version, status: :created, location: @version }
      else
        format.html { render action: "new" }
        format.json { render json: @version.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @version.update_attributes(params[:version])
        make_patch
        format.html { redirect_to application_version_url(@application,@version), notice: 'Version was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @version.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @version.destroy
    # when destroy the last version, re build the path files;
    make_patch
    respond_to do |format|
      format.html { redirect_to application_versions_url(@application) }
      format.json { head :no_content }
    end
  end
end
