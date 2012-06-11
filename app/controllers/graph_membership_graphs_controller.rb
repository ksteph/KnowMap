class GraphMembershipGraphsController < ApplicationController
  # GET /graph_membership_graphs
  # GET /graph_membership_graphs.json
  def index
    @graph_membership_graphs = GraphMembershipGraph.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @graph_membership_graphs }
    end
  end

  # GET /graph_membership_graphs/1
  # GET /graph_membership_graphs/1.json
  def show
    @graph_membership_graph = GraphMembershipGraph.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @graph_membership_graph }
    end
  end

  # GET /graph_membership_graphs/new
  # GET /graph_membership_graphs/new.json
  def new
    @graph_membership_graph = GraphMembershipGraph.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @graph_membership_graph }
    end
  end

  # GET /graph_membership_graphs/1/edit
  def edit
    @graph_membership_graph = GraphMembershipGraph.find(params[:id])
  end

  # POST /graph_membership_graphs
  # POST /graph_membership_graphs.json
  def create
    @graph_membership_graph = GraphMembershipGraph.new(params[:graph_membership_graph])

    respond_to do |format|
      if @graph_membership_graph.save
        format.html { redirect_to @graph_membership_graph, notice: 'Graph membership graph was successfully created.' }
        format.json { render json: @graph_membership_graph, status: :created, location: @graph_membership_graph }
      else
        format.html { render action: "new" }
        format.json { render json: @graph_membership_graph.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /graph_membership_graphs/1
  # PUT /graph_membership_graphs/1.json
  def update
    @graph_membership_graph = GraphMembershipGraph.find(params[:id])

    respond_to do |format|
      if @graph_membership_graph.update_attributes(params[:graph_membership_graph])
        format.html { redirect_to @graph_membership_graph, notice: 'Graph membership graph was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @graph_membership_graph.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /graph_membership_graphs/1
  # DELETE /graph_membership_graphs/1.json
  def destroy
    @graph_membership_graph = GraphMembershipGraph.find(params[:id])
    @graph_membership_graph.destroy

    respond_to do |format|
      format.html { redirect_to graph_membership_graphs_url }
      format.json { head :no_content }
    end
  end
end
