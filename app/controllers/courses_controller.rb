class CoursesController < ApplicationController
  load_and_authorize_resource
  # GET /courses
  # GET /courses.json
  def index
    @courses = Course.all
    
    Action.log :controller => params[:controller], :action => params[:action], :user => current_user

    respond_to do |format|
      format.html { render :layout => !request.xhr? } # index.html.erb
      format.json { render json: @courses }
    end
  end

  # GET /courses/1
  # GET /courses/1.json
  def show
    @course = Course.find(params[:id])
    @course.update_nodes_rank
    
    Action.log :controller => params[:controller], :action => params[:action], :target_id => params[:id], :user => current_user

    respond_to do |format|
      format.html { render :layout => !request.xhr? } # show.html.erb
      format.json { render json: @course }
    end
  end

  # GET /courses/new
  # GET /courses/new.json
  def new
    @course = Course.new
    @course.instructors << current_user
    3.times { @course.instructor_memberships.build }
    10.times { @course.student_memberships.build }
    
    Action.log :controller => params[:controller], :action => params[:action], :user => current_user

    respond_to do |format|
      format.html { render :layout => !request.xhr? } # new.html.erb
      format.json { render json: @course }
    end
  end

  # GET /courses/1/edit
  def edit
    @course = Course.find(params[:id])
    @course.instructor_memberships.build
    3.times { @course.student_memberships.build }
    
    Action.log :controller => params[:controller], :action => params[:action], :target_id => params[:id], :user => current_user
    
    render :layout => !request.xhr?
  end

  # POST /courses
  # POST /courses.json
  def create
    @course = Course.new(params[:course])
    @course.instructors << current_user

    respond_to do |format|
      if @course.save
        Action.log :controller => params[:controller], :action => params[:action], :target_id => @course.id, :user => current_user
        format.html { redirect_to @course, notice: 'Course was successfully created.' }
        format.json { render json: @course, status: :created, location: @course }
      else
        format.html { render action: "new", :layout => !request.xhr? }
        format.json { render json: @course.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /courses/1
  # PUT /courses/1.json
  def update
    @course = Course.find(params[:id])

    respond_to do |format|
      if @course.update_attributes(params[:course])
        Action.log :controller => params[:controller], :action => params[:action], :target_id => params[:id], :user => current_user
        format.html { redirect_to @course, notice: 'Course was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit", :layout => !request.xhr? }
        format.json { render json: @course.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /courses/1
  # DELETE /courses/1.json
  def destroy
    @course = Course.find(params[:id])
    @course.destroy
    
    Action.log :controller => params[:controller], :action => params[:action], :target_id => params[:id], :user => current_user

    respond_to do |format|
      format.html { redirect_to courses_url, notice: 'Course was successfully deleted.' }
      format.json { head :no_content }
    end
  end
  
  def syllabus
    @course = Course.find(params[:course_id])
    @nodes = @course.nodes
    node_ids = @nodes.each { |n| n.id }
    @edges = Edge.where "\"node_id_A\" IN (?) AND \"node_id_B\" IN (?)", node_ids, node_ids
    render 'data'
  end
end
