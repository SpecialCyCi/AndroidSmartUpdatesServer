class ApplicationsController < ApplicationController

  before_filter :authenticate_user!
  before_filter :get_application, :is_has_ability, :except => [:index,:new,:create]

  private

  def get_application
    if Application.exists?(params[:id])
      @application = Application.find(params[:id])
    else
      flash[:notice] = t("application.not_exists_application") and redirect_to :action => :index
    end
  end

  def is_has_ability
    unless @application.user == current_user
      flash[:notice] = t("application.not_current_user_own") and redirect_to :action => :index
    end
  end

  public

  # GET /applications
  # GET /applications.json
  def index
    @applications = current_user.application
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @applications }
    end
  end

  # GET /applications/1
  # GET /applications/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @application }
    end
  end

  # GET /applications/new
  # GET /applications/new.json
  def new
    @application = Application.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @application }
    end
  end

  # GET /applications/1/edit
  def edit

  end

  # POST /applications
  # POST /applications.json
  def create
    @application = Application.new(params[:application])
    @application.user = current_user
    respond_to do |format|
      if @application.save
        format.html { redirect_to @application, notice: 'Application was successfully created.' }
        format.json { render json: @application, status: :created, location: @application }
      else
        format.html { render action: "new" }
        format.json { render json: @application.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /applications/1
  # PUT /applications/1.json
  def update
    respond_to do |format|
      if @application.update_attributes(params[:application])
        format.html { redirect_to @application, notice: 'Application was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @application.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /applications/1
  # DELETE /applications/1.json
  def destroy
    @application.destroy

    respond_to do |format|
      format.html { redirect_to applications_url }
      format.json { head :no_content }
    end
  end
end
