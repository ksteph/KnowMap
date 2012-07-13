class SessionsController < ApplicationController
  def new
    if current_user
      redirect_to root_url, :notice => "Already logged in!"
    else
      render :layout => !request.xhr?
    end
  end

  def create
    user = User.authenticate(params[:email], params[:password])
    if user
      session[:user_id] = user.id
      Action.log :controller => params[:controller], :action => params[:action], :user => current_user
      redirect_to root_url, :flash => { :notice => "Logged in!" }
    else
      flash.now.alert = "Invalid email or password"
      render "new", :layout => !request.xhr?
    end
  end

  def destroy
    Action.log :controller => params[:controller], :action => params[:action], :user => current_user
    session[:user_id] = nil
    redirect_to root_url, :flash => { :notice => "Logged out!" }
  end
end
