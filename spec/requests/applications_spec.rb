require 'spec_helper'

describe "Applications" do
  describe "GET /applications" do
    it "redirect" do
      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
      get applications_path
      response.status.should be(302)
    end
  end
end
