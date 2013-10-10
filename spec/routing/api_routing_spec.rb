require "spec_helper"

describe ApiController do

  before do
    @application_id = "1"
    @package_name = "Tm93IGlzIHRoZSB0aW1lIGZvciBhbGwgZ29vZCBjb2RlcnMKdG8gbGVhcm4g"
    @current_version = "2"
  end

  def should_route_to(route_address)
      get(@url).should route_to(route_address, :application_id => @application_id,:package_name => @package_name, :current_version => @current_version)
  end

  def should_not_route_to(route_address)
      get(@url).should_not route_to(route_address, :application_id => @application_id,:package_name => @package_name, :current_version => @current_version)
  end

  describe "routing to api/update" do

    it "routes to update with right params" do
      @url = get_update_url
      should_route_to("api#update")
    end

    it "routes to update with wrong params" do
      @application_id = "1as"
      @url = get_update_url
      should_not_route_to "api#update"
    end

    it "routes to update with wrong params" do
      @current_version = "1as"
      @url = get_update_url
      should_not_route_to "api#update"
    end

    def get_update_url
      "/api/update/#{@application_id}/#{@package_name}/#{@current_version}"
    end

  end

  describe "routing to api/dowload" do

    it "route to download with right params" do
      @url = get_download_url
      should_route_to("api#download")
    end

    it "route to download with wrong params" do
      @application_id = "22as"
      @url = get_download_url
      should_not_route_to("api#download")
    end

    it "route to download with wrong params" do
      @current_version = "22as"
      @url = get_download_url
      should_not_route_to("api#download")
    end

    def get_download_url
      "/api/download/#{@application_id}/#{@package_name}/#{@current_version}"
    end

  end

end
