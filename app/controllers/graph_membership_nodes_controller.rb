class GraphMembershipNodesController < ApplicationController
  # GET /graph_membership_nodes
  # GET /graph_membership_nodes.json
  def index
    @graph_membership_nodes = GraphMembershipNode.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @graph_membership_nodes }
    end
  end

  # GET /graph_membership_nodes/1
  # GET /graph_membership_nodes/1.json
  def show
    @graph_membership_node = GraphMembershipNode.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @graph_membership_node }
    end
  end

  # GET /graph_membership_nodes/new
  # GET /graph_membership_nodes/new.json
  def new
    @graph_membership_node = GraphMembershipNode.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @graph_membership_node }
    end
  end

  # GET /graph_membership_nodes/1/edit
  def edit
    @graph_membership_node = GraphMembershipNode.find(params[:id])
  end

  # POST /graph_membership_nodes
  # POST /graph_membership_nodes.json
  def create
    @graph_membership_node = GraphMembershipNode.new(params[:graph_membership_node])

    respond_to do |format|
      if @graph_membership_node.save
        format.html { redirect_to @graph_membership_node, notice: 'Graph membership node was successfully created.' }
        format.json { render json: @graph_membership_node, status: :created, location: @graph_membership_node }
      else
        format.html { render action: "new" }
        format.json { render json: @graph_membership_node.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /graph_membership_nodes/1
  # PUT /graph_membership_nodes/1.json
  def update
    @graph_membership_node = GraphMembershipNode.find(params[:id])

    respond_to do |format|
      if @graph_membership_node.update_attributes(params[:graph_membership_node])
        format.html { redirect_to @graph_membership_node, notice: 'Graph membership node was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @graph_membership_node.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /graph_membership_nodes/1
  # DELETE /graph_membership_nodes/1.json
  def destroy
    @graph_membership_node = GraphMembershipNode.find(params[:id])
    @graph_membership_node.destroy

    respond_to do |format|
      format.html { redirect_to graph_membership_nodes_url }
      format.json { head :no_content }
    end
  end
end
