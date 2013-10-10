module Differ::MakeVersionPatch

  # help to make each version patch between all old versions and target version
  def patch(old_versions,new_version)
    remove_folder get_prefix_path new_version
    old_versions.each { |old_version| 
      all_path = get_patch_file_path(old_version, new_version)
      MakeDiffer.applyDiff(old_version.apk.path, new_version.apk.path, all_path)
    }
  end

  # return the patch file path between two version
  def get_patch_file_path(old_version,new_version)
    path = get_prefix_path(new_version)
    create_folder path
    file_name = get_patch_file_name(old_version, new_version)
    all_path  = path + file_name
    all_path
  end

  # reuturn the patch file size between two version
  def get_patch_size(old_version, new_version)
    path = get_patch_file_path(old_version, new_version)
    File.size(path)
  end

  private

  def get_patch_file_name(last_version,new_version)
    "#{last_version.version_code}_#{new_version.version_code}.patch"
  end

  def get_store_path_padding(new_version)
    "user_#{new_version.user_id}/application_#{new_version.application_id}/"
  end

  def get_prefix_path(new_version)
    get_store_path + get_store_path_padding(new_version)
  end
  
  def get_store_path
    sub_path = Rails.env.to_s + "/" unless Rails.env.production?
    sub_path ||= ""
    "#{Rails.root}/public/#{sub_path}patch/"
  end

  def create_folder(path)
    FileUtils.mkdir_p path
  end

  def remove_folder(path)
    FileUtils.rm_rf(Dir[path])
  end

end
