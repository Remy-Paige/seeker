class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  helper_method :current_signed_in

  def after_sign_in_path_for(resource)
    root_path
  end

  def current_signed_in
    if user_signed_in?
      return current_user
    elsif admin_signed_in?
      return current_admin
    end
  end

end