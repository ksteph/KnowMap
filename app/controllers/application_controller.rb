class ApplicationController < ActionController::Base
  protect_from_forgery
  helper_method :current_user
  before_filter :set_path_header
  #around_filter :record_user_action
  
  def partial
    render :partial => "#{params[:partial]}"
  end
  
  def data
    if params[:id] then
      l = params[:id].split(',').map { |x| x.to_i }
      @nodes = Node.find_all_by_id l
      @edges = Edge.where "\"node_id_A\" IN (?) AND \"node_id_B\" IN (?)", l, l
    else
      @nodes = Node.all
      @edges = Edge.all
    end
    render 'data', :format => :json
  end
  
  def log
    Action.log :controller => params[:log_controller], :action => params[:log_action], :target_id => params[:target_id], :user => current_user
    render :nothing => true
  end
  
  private
  
  def record_user_action
    action = params[:action].downcase
    controller = params[:controller].downcase.classify
    #logger.info "##### controller: #{controller}"
    #logger.info "##### action: #{action}"
    #logger.info "##### id: #{params[:id]}"
    #logger.info "##### user: #{current_user}"
    Action.log :controller => params[:controller], :action => params[:action], :target_id => params[:id], :user => sd
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
