class Version < ActiveRecord::Base
  belongs_to :user
  belongs_to :application
  attr_accessible :description, :version_name, :version_code, :apk
  has_attached_file :apk,
                    :path => :get_attached_file_path,
                    :url  => :get_attached_file_url
  validates_attachment_size :apk, :in => 0..ENV["MAX_APK_FILE_SIZE"].to_i.megabytes
  validates :version_code, :presence => true,
                           :numericality => { :greater_than_or_equal_to => 0}
  validates :apk_file_name, allow_blank: true, :format => %r{\.apk}i

  Paperclip.interpolates :user_id do |attachment, style|
    "user_#{attachment.instance.user_id}"
  end

  Paperclip.interpolates :application_id do |attachment, style|
    "application_#{attachment.instance.application_id}"
  end

  Paperclip.interpolates :version_code do |attachment, style|
    "version_code_#{attachment.instance.version_code}"
  end

  def to_json_hash
    { 
      :application_id => application_id, 
      :version_code => version_code, 
      :version_name => version_name,
      :description => description,
      :apk_updated_at => apk_updated_at.to_time.to_i
    }
  end

  def get_padding
    case Rails.env.to_s
    when "development" then "development/"
    when "test" then "test/" 
    when "production" then "" 
    end
  end

  def get_attached_file_path
    ":rails_root/public/#{get_padding}apks/:user_id/:application_id/:version_code.:extension"
  end

  def get_attached_file_url
    "/#{get_padding}apks/:user_id/:application_id/:version_code.:extension"
  end

end
