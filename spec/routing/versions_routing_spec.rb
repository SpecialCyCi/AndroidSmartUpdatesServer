require "spec_helper"

describe VersionsController do
  describe "routing" do

    it "routes to applicaiton's version list #show" do
        get("/applications/1/versions").should route_to("versions#index", :application_id=> "1")
    end

    it "routes to #new" do
      get("/applications/1/versions/new").should route_to("versions#new", :application_id=> "1")
    end

    it "routes to #show" do
      get("/applications/1/versions/1").should route_to("versions#show", :application_id=> "1", :id => "1")
    end

    it "routes to #edit" do
      get("/applications/1/versions/1/edit").should route_to("versions#edit", :application_id=> "1", :id => "1")
    end

    it "routes to #create" do
      post("/applications/1/versions").should route_to("versions#create", :application_id=> "1")
    end

    it "routes to #update" do
      put("/applications/1/versions/1").should route_to("versions#update", :application_id=> "1", :id => "1")
    end

    it "routes to #destroy" do
      delete("/applications/1/versions/1").should route_to("versions#destroy", :application_id=> "1", :id => "1")
    end

  end

end
