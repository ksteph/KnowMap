class UsersController < ApplicationController
  def new
    if current_user
      redirect_to root_url
    else
      @user = User.new
      render :layout => !request.xhr?
    end
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      redirect_to root_url, :notice => "Signed up!"
    else
      render "new", :layout => !request.xhr?
    end
  end
end
