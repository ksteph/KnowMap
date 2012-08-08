class UsersController < ApplicationController
  load_and_authorize_resource
  
  # GET /users
  # GET /users.json
  def index
    @users = User.all
    
    Action.log :controller => params[:controller], :action => params[:action], :user => current_user

    respond_to do |format|
      format.html { render :layout => !request.xhr? } # index.html.erb
      format.json { render json: @users }
    end
  end

  # GET /users/1
  # GET /users/1.json
  def show
    @user = User.find(params[:id])

    Action.log :controller => params[:controller], :action => params[:action], :target_id => params[:id], :user => current_user

    respond_to do |format|
      format.html { render :layout => !request.xhr? } # show.html.erb
      format.json { render json: @user }
    end
  end

  # GET /users/new
  # GET /users/new.json
  def new
    if current_user
      redirect_to root_url
    else
      @user = User.new
      render :layout => !request.xhr?
    end
  end

  # GET /users/1/edit
  def edit
    @user = User.find(params[:id])
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(params[:user], :as => current_user.role)
    
    if @user.save
      Action.log :controller => params[:controller], :action => params[:action], :user => @user
      redirect_to root_url, :notice => "Signed up!"
    else
      render "new", :layout => !request.xhr?
    end
  end

  # PUT /users/1
  # PUT /users/1.json
  def update
    @user = User.find(params[:id])

    respond_to do |format|
      if @user.update_attributes(params[:user], :as => current_user.role)
        Action.log :controller => params[:controller], :action => params[:action], :target_id => params[:id], :user => current_user
        format.html { redirect_to @user, notice: 'User was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit", :layout => !request.xhr? }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user = User.find(params[:id])
    @user.destroy

    Action.log :controller => params[:controller], :action => params[:action], :target_id => params[:id], :user => current_user

    respond_to do |format|
      format.html { redirect_to users_url }
      format.json { head :no_content }
    end
  end
  
  def profile
    @user = current_user

    Action.log :controller => params[:controller], :action => params[:action], :user => current_user
    
    render "show", :layout => !request.xhr?
  end
end
