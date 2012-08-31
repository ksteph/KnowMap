class UsersController < ApplicationController
  load_and_authorize_resource :except => [:create]
  
  # GET /users
  # GET /users.json
  def index
    @users = User.all
    
    Action.log :controller => params[:controller], :action => params[:action], :user => current_user

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @users }
    end
  end

  # GET /users/1
  # GET /users/1.json
  def show
    @user = User.find(params[:id])

    Action.log :controller => params[:controller], :action => params[:action], :target_id => params[:id], :user => current_user

    respond_to do |format|
      format.html # show.html.erb
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
    end
  end

  # GET /account/edit
  # GET /users/1/edit
  def edit
    if params.has_key? :id then
      @user = User.find(params[:id])
    else
      @user = current_user
    end
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(params[:user], :as => can?(:change_role, User) ? :change_role : :new)
    
    if @user.save
      Action.log :controller => params[:controller], :action => params[:action], :user => @user
      redirect_to root_url, :notice => "Signed up!"
    else
      render "new"
    end
  end

  # PUT /users/1
  # PUT /users/1.json
  def update
    @user = User.find(params[:id])

    if @user.update_attributes(params[:user], :as => can?(:change_role, User) ? :change_role : :update)
      Action.log :controller => params[:controller], :action => params[:action], :target_id => params[:id], :user => current_user
      redirect_to current_user == @user ? account_path : @user, notice: 'User was successfully updated.'
    else
      render action: "edit"
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
  
  # GET /account
  def account
    @user = current_user
    redirect_to :root unless @user
    render 'show'
  end
  
  # GET /account/change_password
  def change_password
    @user = current_user
    if request.post?
      redirect_to change_password_path and flash[:error] = 'The current password you entered is invalid.' and return unless current_user == User.authenticate(current_user.email, params[:user][:current_password])
      @user.password = params[:user][:new_password]
      @user.password_confirmation = params[:user][:new_password_confirmation]
      @user.updating_password = true
      if @user.save
        redirect_to account_path, notice: 'Password successfully updated.'
      else
        render 'change_password'
      end
    else
      render 'change_password'
    end
  end
  
  def profile
    @user = current_user

    Action.log :controller => params[:controller], :action => params[:action], :user => current_user
    
    render "show"
  end
end
