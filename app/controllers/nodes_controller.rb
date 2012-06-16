class NodesController < ApplicationController
  # GET /nodes
  # GET /nodes.json
  def index
    @nodes = Node.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @nodes }
    end
  end

  # GET /nodes/1
  # GET /nodes/1.json
  def show
    @node = Node.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @node }
    end
  end

  # GET /nodes/new
  # GET /nodes/new.json
  def new
    @node = Node.new
    3.times { @node.related_edges_B.build }
    3.times { @node.incoming_edges.build }
    3.times { @node.outgoing_edges.build }

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @node }
    end
  end

  # GET /nodes/1/edit
  def edit
    @node = Node.find(params[:id])
    @node.related_edges_B.build
    @node.incoming_edges.build
    @node.outgoing_edges.build
  end

  # POST /nodes
  # POST /nodes.json
  def create
    @node = Node.new(params[:node])

    respond_to do |format|
      if @node.save
        format.html { redirect_to @node, notice: 'Node was successfully created.' }
        format.json { render json: @node, status: :created, location: @node }
      else
        @node.related_edges_B.build
        @node.incoming_edges.build
        @node.outgoing_edges.build
        format.html { render action: "new" }
        format.json { render json: @node.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /nodes/1
  # PUT /nodes/1.json
  def update
    @node = Node.find(params[:id])
    
    #params[:incoming_edges_attributes] and params[:incoming_edges_attributes].each { |i| i[:node_id_B] = @node.id and i[:edgetype] = Edgetype.find_by_name('dependent') }
    #params[:outgoing_edges_attributes] and params[:outgoing_edges_attributes].each { |i| i[:node_id_A] = @node.id and i[:edgetype] = Edgetype.find_by_name('dependent') }

    respond_to do |format|
      if @node.update_attributes(params[:node])
        format.html { redirect_to @node, notice: 'Node was successfully updated.' }
        format.json { head :no_content }
      else
        @node.related_edges_B.build
        @node.incoming_edges.build
        @node.outgoing_edges.build
        format.html { render action: "edit" }
        format.json { render json: @node.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /nodes/1
  # DELETE /nodes/1.json
  def destroy
    @node = Node.find(params[:id])
    @node.destroy

    respond_to do |format|
      format.html { redirect_to nodes_url }
      format.json { head :no_content }
    end
  end
end
