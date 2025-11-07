class ApplicationController < ActionController::Base
  include Pundit::Authorization
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  allow_browser versions: :modern

  stale_when_importmap_changes

  helper_method :current_user

  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end

  def require_login
    unless current_user
      redirect_to login_path, alert: "You must log in first."
    end
  end

  private

  def user_not_authorized
    flash[:alert] = "You do not have permission to perform this action."
    redirect_back(fallback_location: teams_path)
  end
end
