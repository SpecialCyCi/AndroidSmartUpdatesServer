include Differ::MakeVersionPatch

class ApplicationController < ActionController::Base

  WillPaginate.per_page = 10

  protect_from_forgery

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_path, :alert => exception.message
  end

end
