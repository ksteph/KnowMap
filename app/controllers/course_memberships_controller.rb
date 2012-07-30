class CourseMembershipsController < ApplicationController
  # GET /course_memberships
  # GET /course_memberships.json
  def index
    @course_memberships = CourseMembership.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @course_memberships }
    end
  end

  # GET /course_memberships/1
  # GET /course_memberships/1.json
  def show
    @course_membership = CourseMembership.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @course_membership }
    end
  end

  # GET /course_memberships/new
  # GET /course_memberships/new.json
  def new
    @course_membership = CourseMembership.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @course_membership }
    end
  end

  # GET /course_memberships/1/edit
  def edit
    @course_membership = CourseMembership.find(params[:id])
  end

  # POST /course_memberships
  # POST /course_memberships.json
  def create
    @course_membership = CourseMembership.new(params[:course_membership])

    respond_to do |format|
      if @course_membership.save
        format.html { redirect_to @course_membership, notice: 'Course membership was successfully created.' }
        format.json { render json: @course_membership, status: :created, location: @course_membership }
      else
        format.html { render action: "new" }
        format.json { render json: @course_membership.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /course_memberships/1
  # PUT /course_memberships/1.json
  def update
    @course_membership = CourseMembership.find(params[:id])

    respond_to do |format|
      if @course_membership.update_attributes(params[:course_membership])
        format.html { redirect_to @course_membership, notice: 'Course membership was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @course_membership.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /course_memberships/1
  # DELETE /course_memberships/1.json
  def destroy
    @course_membership = CourseMembership.find(params[:id])
    @course_membership.destroy

    respond_to do |format|
      format.html { redirect_to course_memberships_url }
      format.json { head :no_content }
    end
  end
end
