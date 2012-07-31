class NodeIndicesController < ApplicationController
  # GET /node_indices
  # GET /node_indices.json
  def index
    @node_indices = NodeIndex.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @node_indices }
    end
  end

  # GET /node_indices/1
  # GET /node_indices/1.json
  def show
    @node_index = NodeIndex.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @node_index }
    end
  end

  # GET /node_indices/new
  # GET /node_indices/new.json
  def new
    @node_index = NodeIndex.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @node_index }
    end
  end

  # GET /node_indices/1/edit
  def edit
    @node_index = NodeIndex.find(params[:id])
  end

  # POST /node_indices
  # POST /node_indices.json
  def create
    @node_index = NodeIndex.new(params[:node_index])

    respond_to do |format|
      if @node_index.save
        format.html { redirect_to @node_index, notice: 'Node index was successfully created.' }
        format.json { render json: @node_index, status: :created, location: @node_index }
      else
        format.html { render action: "new" }
        format.json { render json: @node_index.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /node_indices/1
  # PUT /node_indices/1.json
  def update
    @node_index = NodeIndex.find(params[:id])

    respond_to do |format|
      if @node_index.update_attributes(params[:node_index])
        format.html { redirect_to @node_index, notice: 'Node index was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @node_index.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /node_indices/1
  # DELETE /node_indices/1.json
  def destroy
    @node_index = NodeIndex.find(params[:id])
    @node_index.destroy

    respond_to do |format|
      format.html { redirect_to node_indices_url }
      format.json { head :no_content }
    end
  end
end
