require 'spec_helper'

describe Application do

  before(:each) do
    @user = create(:user)
    @attr = {
      :app_name => "iSCAU",
      :package_name => "cn.scau.scautreasure",
      :description => "none special"
    }
  end

  describe "new a application with wrong params" do

    it "with no app_name" do
      app = Application.new(@attr.merge(:app_name => ""))
      app.should_not be_valid
    end

    it "with too long app_name" do
      app_name = "a" * 400
      app = Application.new(@attr.merge(:app_name => app_name))
      app.should_not be_valid
    end

    it "with no package_name" do
      app = Application.new(@attr.merge(:package_name => ""))
      app.should_not be_valid
    end

    it "with none description" do
      app = Application.new(@attr.merge(:description=> nil))
      app.should be_valid
    end

    it "with too long description" do
      app = Application.new(@attr.merge(:description=> "a"*999))
      app.should_not be_valid
    end

    it "with wrong format package_name" do
      wrongpackage_name = %w[123 cnm 12asd .]
      wrongpackage_name.each do |package_name|
          app = Application.new(@attr.merge(:package_name => package_name))
          app.should_not be_valid
      end
    end

    it "with user id" do
      expect{
        app = Application.new(@attr.merge(:user_id => 1))
        app.save
      }.to raise_error
    end
  end

  describe "new a application with already existed params" do

    before do 
      Application.new(@attr).save
    end

    it "with already app name  in current user applcations list" do
      app = Application.new(@attr.merge(:package_name => "cn.scau1.sca"))
      app.should_not be_valid
    end

    it "with already package name in current user applcations list" do
      app = Application.new(@attr.merge(:app_name => "iSCAU1"))
      app.should_not be_valid
    end

  end

  describe "new a application with right params" do

    it "all params are right" do
        app = Application.new(@attr)
        app.save.should be_true
        anotherApp = Application.find(app.id)
        anotherApp.should eq(app)
    end

  end

  describe "update a application" do

    it "with change user id" do
      expect{
        app = Application.new(@attr)
        app.update_attributes(:user_id => 2222)
      }.to raise_error
    end

      it "with change other params" do
      app = Application.new(@attr)
      app.update_attributes(:app_name => "2222").should be_true
    end
  end

end
