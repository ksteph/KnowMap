class EdgetypesController < ApplicationController
  # GET /edgetypes
  # GET /edgetypes.json
  def index
    @edgetypes = Edgetype.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @edgetypes }
    end
  end

  # GET /edgetypes/1
  # GET /edgetypes/1.json
  def show
    @edgetype = Edgetype.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @edgetype }
    end
  end

  # GET /edgetypes/new
  # GET /edgetypes/new.json
  def new
    @edgetype = Edgetype.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @edgetype }
    end
  end

  # GET /edgetypes/1/edit
  def edit
    @edgetype = Edgetype.find(params[:id])
  end

  # POST /edgetypes
  # POST /edgetypes.json
  def create
    @edgetype = Edgetype.new(params[:edgetype])

    respond_to do |format|
      if @edgetype.save
        format.html { redirect_to @edgetype, notice: 'Edgetype was successfully created.' }
        format.json { render json: @edgetype, status: :created, location: @edgetype }
      else
        format.html { render action: "new" }
        format.json { render json: @edgetype.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /edgetypes/1
  # PUT /edgetypes/1.json
  def update
    @edgetype = Edgetype.find(params[:id])

    respond_to do |format|
      if @edgetype.update_attributes(params[:edgetype])
        format.html { redirect_to @edgetype, notice: 'Edgetype was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @edgetype.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /edgetypes/1
  # DELETE /edgetypes/1.json
  def destroy
    @edgetype = Edgetype.find(params[:id])
    @edgetype.destroy

    respond_to do |format|
      format.html { redirect_to edgetypes_url }
      format.json { head :no_content }
    end
  end
end
