class ApplicationController < ActionController::Base
  protect_from_forgery
  helper_method :current_user
  before_filter :set_path_header
  
  def partial
    render :partial => "layouts/#{params[:partial]}"
  end
  
  private

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end
  
  def set_path_header
    response.headers["X-APP-PATH"] = request.fullpath()
  end
end
