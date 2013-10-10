require 'spec_helper'

describe ApiController do

  before do
    # load preinstall versions
    @user = FactoryGirl.create(:user)
    @application = @user.application[0]
    build_version_patch
    @current_version = @application.version.first
    @last_version = @application.version.last
  end

  describe "get update information" do

    it "with a not exist application" do
      @application.stub(:to_param).and_return 99999
      visit_update
      response.body.should eq application_not_existed_json.to_json
    end

    it "with a not match package name" do
      @application.stub(:package_name).and_return "com.special"
      visit_update
      response.body.should eq package_name_not_match_json.to_json
    end

    it "with an exist application,but current version is not existed" do
      @current_version.stub(:version_code).and_return 9999
      visit_update
      response.body.should eq current_version_not_existed_json.to_json
    end

    it "with an exist application,but application's versions is empty." do
      Version.destroy @application.version
      visit_update
      response.body.should eq current_version_not_existed_json.to_json
    end

    it "with an exist application and current version, and current version is equal last version" do
      @current_version = @application.version.last
      visit_update
      response.body.should eq no_update_json.to_json
    end

    it "with an exist application and current version, and current version is lower than last version" do
      visit_update
      response.body.should eq has_update_json.to_json
    end

    def visit_update
      get :update, {:application_id => @application.to_param, :package_name => Base64.urlsafe_encode64(@application.package_name), 
                    :current_version => @current_version.version_code}
    end

  end

  describe "get download" do

    it "with an existed application, and current version" do
      visit_download
      path = Differ::MakeVersionPatch.get_patch_file_path(@current_version, @last_version)
      response.body.bytes.should eq File.read(path).bytes
    end

    it "with a not existed application" do
      @application.stub(:to_param).and_return 9999
      visit_download
      response.body.should eq application_not_existed_json.to_json              
    end

    it "with a not existed current_version" do
      @current_version.stub(:version_code).and_return 999
      visit_download
      response.body.should eq current_version_not_existed_json.to_json              
    end

    it "with a not existed package name" do
      @application.stub(:package_name).and_return "special"
      visit_download
      response.body.should eq package_name_not_match_json.to_json              
    end

    def visit_download
      get :download, {:application_id => @application.to_param, :package_name => Base64.urlsafe_encode64(@application.package_name), 
                    :current_version => @current_version.version_code}
    end

  end

  def no_update_json
    {"message" => "no_update", "information" => nil}
  end

  def application_not_existed_json
    {"message" => "application_not_existed", "information" => nil}
  end

  def current_version_not_existed_json
    {"message" => "current_version_not_existed", "information" => nil}
  end

  def package_name_not_match_json
    {"message" => "package_name_not_match", "information" => nil}
  end

  def has_update_json
    {"message" => "has_update", "information" => 
      {
        "application_id" => @application.id, 
        "version_code" => @last_version.version_code,
        "version_name" => @last_version.version_name, 
        "description" => @last_version.description,
        "apk_updated_at" => @last_version.apk_updated_at.to_time.to_i,
        "apk_patch_size" => Differ::MakeVersionPatch.get_patch_size(@current_version, @last_version)
      }
    }
  end

  def build_version_patch
    create_version
    make_version_path
  end

  def create_version
    @all_version = 1.upto(20).map do |n|
        version = FactoryGirl.build(:version)
        version.apk_updated_at = DateTime.now
        version.application_id = @application.id
        version.save
        version.stub(:apk).and_return get_apk_double(n)
        version
    end
  end

  def make_version_path
    @need_path_version = @all_version[0..@all_version.count-2]
    Differ::MakeVersionPatch.patch @need_path_version, @all_version.last
  end

  def get_apk_double(n)
      apk = double("Attachment")
      apk.stub(:path).and_return("#{Rails.root}/spec/assets/version_#{n}.apk")
      apk
  end

  after(:each) do
    FileUtils.rm_rf(Dir["#{Rails.root}/public/test/"])
  end

end
