class Application < ActiveRecord::Base
  belongs_to :user
  has_many :version
  attr_accessible :app_name, :description,:package_name
  attr_readonly :package_name
  validates :app_name, :presence => true,
                      :length => {:maximum => 255},
                      :uniqueness => {:scope => :user_id}
  validates :package_name, :presence => true,
                          :uniqueness => {:scope => :user_id},
                          :format => /(\S+)\.(\S+)/
  validates :description, :length=>{:maximum => 500}

end
