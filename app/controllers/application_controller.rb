class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  private

  def current_user
    @current_user = TempUser.find(session[:active_id]) if session[:user_type]
    #XYZ
    @current_user||= User.find(session[:user_id]) if session[:user_id]
  end

  def ensure_logged_in
    unless current_user
      flash[:alert] = "Please Log In"
      redirect_to new_session_path
    end
  end

  helper_method :current_user

end
