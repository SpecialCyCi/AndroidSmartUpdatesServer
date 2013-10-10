require 'spec_helper'

describe Differ::MakeVersionPatch do

  before do
    @store_path = "#{Rails.root}/public/test/patch/"
    @all_version = 1.upto(20).map do |n|
        version = FactoryGirl.build(:version)
        version.application_id = 1
        version.stub(:apk).and_return get_apk_double(n)
        version
    end
  end

  def get_apk_double(n)
      apk = double("Attachment")
      apk.stub(:path).and_return("#{Rails.root}/spec/assets/version_#{n}.apk")
      apk
  end

  it "make all versions patch" do
    make_version_patch 20
  end

  it "make all versions patch twice, to sure has deleted the last time patch files" do
    make_version_patch 19
    store_sub_path = "user_1/application_1/"
    patch_file_name = "19_20.patch"
    File.exists?("#{@store_path}#{store_sub_path}#{patch_file_name}").should be_false
  end

  def make_version_patch(version_count)
    @need_path_version = @all_version[0..@all_version.count-2]
    Differ::MakeVersionPatch.patch @need_path_version, @all_version.last

    @store_sub_path = "user_#{@all_version.last.user_id}/application_#{@all_version.last.application_id}/"
    version_count.times do |n|
      patch_file_name = "#{@all_version[n].version_code}_#{@all_version.last.version_code}.patch"
      check_get_patch_size @all_version[n], @all_version.last if n != 19
      File.exists?("#{@store_path}#{@store_sub_path}#{patch_file_name}").should eq n != 19
    end

  end

  def check_get_patch_size(old_version,new_version)
    size = Differ::MakeVersionPatch.get_patch_size(old_version, new_version)
    patch_file_name = "#{old_version.version_code}_#{new_version.version_code}.patch"
    File.size("#{@store_path}#{@store_sub_path}#{patch_file_name}").should eq size
  end

  after(:all) do
    FileUtils.rm_rf(Dir[@store_path])
  end
  
end