require 'spec_helper'

describe VersionsController do

  before do
    @user = FactoryGirl.create(:has_version_model_user)
    sign_in @user
  end

  def should_flash_and_redirect
      flash[:notice].should_not be_nil
      response.should redirect_to root_url
  end

  describe "GET index" do
 
   it "open a application's version list, but it's not belongs to current user" do
      application = FactoryGirl.create(:others_application)
      get :index, {:application_id => application}
      should_flash_and_redirect
    end

    it "open a application's version list, and it's belongs to current user" do
      get :index, {:application_id => @user.application[0]}
      versions = @user.application[0].version
      assigns(:versions).should eq(versions)
      assigns(:versions).count.should_not eq(0)
    end

  end

  describe "GET show" do

    it "open a not exist version id" do
      get :show, {:id => 11111,:application_id => @user.application[0]}
      flash[:notice].should_not be_nil
      response.should redirect_to root_url
    end

    it "open exist version id, but it did not belongs to current user" do
      version = FactoryGirl.create(:others_user_version)
      get :show, {:id => version.to_param,:application_id => version.application_id}
      should_flash_and_redirect
    end

    it "open an existed application id, and it's belongs to current user" do
      get :show, {:id => @user.application[0].version[0].to_param,
                  :application_id => @user.application[0]}
      assigns(:version).should eq @user.application[0].version[0]
    end

  end

  describe "GET new" do

    it "create a new version but target application is not belongs to user" do
      application = FactoryGirl.create(:others_application)
      get :new, :application_id => application
      should_flash_and_redirect
    end

    it "create a new version,and target application is belongs to user" do
      get :new, :application_id => @user.application[0]
      assigns(:version).should_not be_nil
    end

  end

  describe "GET edit" do

    it "edit an not exist application id" do
      get :edit, {:id => @user.application[0].version[0], :application_id => 9999}
      assigns(:version).should be_nil
      assigns(:application).should be_nil
      should_flash_and_redirect
    end

    it "edit an not exist version id" do
      get :edit, {:id => 999999, :application_id => @user.application[0]}
      assigns(:version).should be_nil
      should_flash_and_redirect
    end

    it "edit an exist version id,but it did not belongs to current user" do
      version = FactoryGirl.create(:others_user_version)
      get :edit, {:id => version,:application_id => version.application_id}
      assigns(:version).should be_nil
      assigns(:application).should be_nil
      should_flash_and_redirect
    end

    it "edit an exist version id,but it is not the last version" do
      version = @user.application[0].version.first
      get :edit, {:id => version, :application_id => version.application_id}
      should_flash_and_redirect
    end

    it "edit an exist version id, and it belongs to current user" do
      version = @user.application[0].version.last
      get :edit, {:id => version, :application_id => version.application_id}
      assigns(:version).should_not be_nil
      assigns(:application).should_not be_nil
      flash[:notice].should be_nil
    end
  end


  describe "POST create" do
    
    def apk_document
      test_apk = "#{Rails.root}/spec/assets/version_9.apk"
      Rack::Test::UploadedFile.new(test_apk, "application/octet-stream")
    end

    before do
      @version = FactoryGirl.attributes_for(:version)
      @version.delete :user_id
      @version.merge!({:apk => apk_document})

      # reset the application
      @application = FactoryGirl.build(:application)
      @application.package_name = "cn.scau.scautreasure"
      @application.user = @user
      @application.save
      Version.destroy(@application.version.all)
    end

    it "create a new version, but the application do not belongs current user" do
      application = FactoryGirl.create(:others_application)
      expect_post_change(application, 0)
      response.should redirect_to root_url
    end

    it "create a new version, but the package name is not match the application's" do
      expect_post_change(@user.application[0], 0)
      flash[:notice].should_not be_nil
      response.should render_template "new"
    end

    it "create a new version, and version code is higher than the newest version" do
      create_assign_version(:version_code_8_version)
      expect_post_change(@application, 1)
      assigns_version_right
      response.should redirect_to application_version_url(@application,assigns(:version))
    end

    it "create a new version, but version code is equal the newest version" do
      create_assign_version(:version_code_9_version)
      expect_post_change(@application, 0)
      flash[:notice].should_not be_nil
      response.should render_template "new"
    end

    it "create a new version, but version code is lower than the newest version" do
      create_assign_version(:version_code_10_version)
      expect_post_change(@application, 0)
      flash[:notice].should_not be_nil
      response.should render_template "new"
    end

    def create_assign_version(version_x)
      version = FactoryGirl.build(version_x)
      version.application_id = @application.id
      version.save
    end

    def expect_post_change(target_application, change_amount) 
      expect{
        post :create, :version => @version, :application_id => target_application
      }.to change(Version, :count).by(change_amount)
    end

    def assigns_version_right
      assigns(:version).application_id.should eq @application.id
      assigns(:version).user.should eq @user
      assigns(:version).version_code.should eq 9
    end

  end


  describe "PUT update" do

    before do
      @version = FactoryGirl.build(:version)
      @other_user =  FactoryGirl.create :other_user
    end

    it "updates the requested version with valid params" do
      version = @user.application[0].version.last
      Version.any_instance.should_receive(:update_attributes).with({ "version_code" => "1000"})
      put :update, {:id => version, :version => { "version_code" => "1000"},:application_id => @user.application[0].id }
      assigns(:version).should eq(version)
    end

    it "updates the requested version with valid params, but target version is not the last version" do
      build_version @user
      Version.any_instance.should_not_receive(:update_attributes).with({ "version_code" => "1000"})
      put :update, {:id => @user.application[0].version.first, :version => { "version_code" => "1000"},:application_id => @user.application[0].id }
      should_flash_and_redirect
    end

    it "updates the requested version which is not belongs to current user" do
      build_version @other_user
      put :update, {:id => @version.to_param, :version => { "version_code" => "1000"},:application_id => @user.application[0].id }
      should_flash_and_redirect
    end

    def build_version(user)
      @version.application = @user.application[0]
      @version.user = user
      @version.save
    end
  end

  describe "DELETE destroy" do

    it "delete a not exist version" do
      expect{
        delete :destroy, {:id => 999999,:application_id => 99}
      }.to change(Version, :count).by(0)
      should_flash_and_redirect
    end

    it "delete a exist version but it is not belongs to current user" do
      version = FactoryGirl.create(:others_user_version)
      expect{
        delete :destroy, {:id => version, :application_id => version.application_id}
      }.to change(Version, :count).by(0)
      should_flash_and_redirect
    end

    it "delete a exist version but which is not the last version" do
      app = @user.application[0]
      expect{
        delete :destroy, {:id => app.version[0], :application_id => app.id}
      }.to change(Version, :count).by(0)
      should_flash_and_redirect
    end

    it "delete a exist version and all right" do
      app = @user.application[0]
      expect{
        delete :destroy, {:id => app.version.last, :application_id => app.id}
      }.to change(Version, :count).by(-1)
      response.should redirect_to application_versions_url(app) 
    end

  end

  describe "Access version without sign_in" do

    before do
      sign_out @user
    end

    it "Access Show" do
      app = @user.application[0]
      get :show, {:id => app.version[0],:application_id => app}
      assigns(:version).should be_nil
      response.should redirect_to new_user_session_path
    end
    
  end

  after do
    FileUtils.rm_rf(Dir["#{Rails.root}/public/test/"])
  end
  
end
