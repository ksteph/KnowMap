class ApplicationController < ActionController::Base
  protect_from_forgery
  helper_method :current_user
  before_filter :set_path_header
  around_filter :record_user_action
  
  def partial
    render :partial => "layouts/#{params[:partial]}"
  end
  
  private
  
  def record_user_action
    action = params[:action].downcase
    controller = params[:controller].downcase.classify
    #logger.info "##### controller: #{controller}"
    #logger.info "##### action: #{action}"
    #logger.info "##### id: #{params[:id]}"
    #logger.info "##### user: #{current_user}"
    user = current_user
    yield
    user = current_user if not user
    if @user and action == "create" and not user then
      user = @user
    end
    if user and ((not ["create", "update"].include? action) or (["create", "update"].include? action and self.status == 302)) and not ["Application", "Action"].include? controller then
      user.actions.create(
        :controller => controller,
        :action => action,
        :target_id => params[:id]
      )
      
      logger.info user.actions.last
    end
  end

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end
  
  def set_path_header
    response.headers["X-APP-PATH"] = request.fullpath()
  end
  
  rescue_from CanCan::AccessDenied do |exception|
    flash[:error] = "Access denied."
    redirect_to root_url
  end
end
