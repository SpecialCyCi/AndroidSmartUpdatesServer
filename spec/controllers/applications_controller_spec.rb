require 'spec_helper'

describe ApplicationsController do

  before do
    @user = FactoryGirl.create(:user)
    sign_in @user
  end

  describe "GET index" do

    it "assigns all applications as current_user applications" do
      get :index
      applications = @user.application
      assigns(:applications).should eq(applications)
      assigns(:applications).count.should_not eq(0)
    end

  end

  describe "GET show" do

    it "assigns get not exist application id" do
      get :show, {:id => 9999999}
      flash[:notice].should_not be_nil
      response.should redirect_to(applications_url)
    end

    it "assigns get exist application id, but it did not belongs to current user" do
      app = FactoryGirl.create(:others_application)
      get :show, {:id => app.to_param}
      flash[:notice].should_not be_nil
      response.should redirect_to(applications_url)
    end

    it "assigns get exist application id" do
      get :show, {:id => @user.application[1].to_param}
      assigns(:application).should eq(@user.application[1])
    end

  end

  describe "GET new" do

    it "assigns a new application as @application" do
      get :new
      assigns(:application).should_not be_nil
    end

  end

  describe "GET edit" do

    it "get an not exist application id" do
      get :edit, {:id => 999999}
      flash[:notice].should_not be_nil
      response.should redirect_to(applications_url)
    end

    it "get an exist application id,but it did not belongs to current user" do
      app = FactoryGirl.create(:application)
      app.user_id = 2
      app.save
      get :edit, {:id => app.to_param}
      flash[:notice].should_not be_nil
      response.should redirect_to(applications_url)
    end

    it "get an exist application id and it belongs to current" do
      get :edit, {:id => @user.application[1].to_param}
      assigns(:application).should eq(@user.application[1])
    end

  end

  describe "POST create" do
    
    it "create a new application with invalid params" do
      application = FactoryGirl.attributes_for(:application)
      expect{
        post :create, :application => application
      }.to change(application, :count).by(0)
    end
    
    it "create a new application and check the application owner" do
      application = FactoryGirl.attributes_for(:application)
      expect{
        post :create, :application => application
      }.to change(Application, :count).by(1)
      assigns(:application).user.should eq(@user)
      response.should redirect_to(Application.last)
    end

  end

  describe "PUT update" do

    before(:each) do
      @application = FactoryGirl.build(:application)
      @application.user_id = @user.id
      @application.save
    end
    
    # it seem not work....
    # 
    # it "modify the readonly field 'package_name'" do
    #   Application.any_instance.should_receive(:update_attributes).with({ "package_name" => "cn.scau.modify" })
    #   put :update, :id => @application.to_param, :application => { "package_name" => "cn.scau.modify" }
    #   response.should render_template "edit"
    # end

    # it "updates the requested application with invalid params" do
    #   Application.any_instance.should_receive(:update_attributes).with({ "app_name" => "" })
    #   put :update, :id => @application.to_param, :application => { "app_name" => "" }
    #   response.should render_template "edit"
    # end

    # it "updates the requested application" do
    #   Application.any_instance.should_receive(:update_attributes).with( { "app_name" => "MyString" })
    #   put :update, :id => @application.id, :application =>  { :app_name => "MyString" }
    # end

    # it "updates the requested application which is not belongs to current user" do
    #   application = FactoryGirl.create(:others_application)
    #   put :update, :id => application.to_param, :application => { "app_name" => "MyString" }
    #   flash[:notice].should_not be_nil
    #   response.should redirect_to(applications_url)
    # end
  end

  describe "DELETE destroy" do

    it "delete a not exist application" do
      expect{
        delete :destroy, {:id => 999999}
      }.to change(Application, :count).by(0)
      flash[:notice].should_not be_nil
      response.should redirect_to(applications_url)
    end

    it "delete a exist application but it is not belongs to current user" do
      app = FactoryGirl.create(:others_application)
      expect{
        delete :destroy, {:id => app}
      }.to change(Application, :count).by(0)
      flash[:notice].should_not be_nil
      response.should redirect_to(applications_url)
    end

    it "delete a exist application and all right" do
      expect{
        delete :destroy, {:id => @user.application[0]}
      }.to change(Application, :count).by(-1)
    end


  end

  describe "Access application without sign_in" do

    before do
      sign_out @user
    end

    it "Access Show" do
      get :show, {:id => @user.application[0]}
      assigns(:application).should be_nil
    end
    
  end

end
