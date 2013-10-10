require 'spec_helper'

describe Version do

  before do
    @attr = {
      :version_code => 1,
      :description => nil,
    }
  end

  describe "new with wrong params" do
  
    it "with an empty version code" do
      version = Version.new(@attr.merge(:version_code => nil))
      version.should_not be_valid
    end

    it "with an version less than 0" do
      version = Version.new(@attr.merge(:version_code => -1))
      version.should_not be_valid
    end
    
  end


end
