class GraphsController < ApplicationController
  # GET /graphs
  # GET /graphs.json
  def index
    @graphs = Graph.all

    respond_to do |format|
      format.html { render :layout => !request.xhr? } # index.html.erb
      format.json { render json: @graphs }
    end
  end

  # GET /graphs/1
  # GET /graphs/1.json
  def show
    @graph = Graph.find(params[:id])

    respond_to do |format|
      format.html { render :layout => !request.xhr? } # show.html.erb
      format.json { render json: @graph }
    end
  end

  # GET /graphs/new
  # GET /graphs/new.json
  def new
    @graph = Graph.new
    3.times { @graph.graph_membership_graphs.build }
    3.times { @graph.graph_membership_nodes.build }

    respond_to do |format|
      format.html { render :layout => !request.xhr? } # new.html.erb
      format.json { render json: @graph }
    end
  end

  # GET /graphs/1/edit
  def edit
    @graph = Graph.find(params[:id])
    @graph.graph_membership_graphs.build
    @graph.graph_membership_nodes.build
    render :layout => !request.xhr?
  end

  # POST /graphs
  # POST /graphs.json
  def create
    @graph = Graph.new(params[:graph])

    respond_to do |format|
      if @graph.save
        format.html { redirect_to @graph, notice: 'Graph was successfully created.' }
        format.json { render json: @graph, status: :created, location: @graph }
      else
        @graph.graph_membership_graphs.build
        @graph.graph_membership_nodes.build
        format.html { render action: "new", :layout => !request.xhr? }
        format.json { render json: @graph.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /graphs/1
  # PUT /graphs/1.json
  def update
    @graph = Graph.includes(:nodes).find(params[:id])

    respond_to do |format|
      if @graph.update_attributes(params[:graph])
        format.html { redirect_to @graph, notice: 'Graph was successfully updated.' }
        format.json { head :no_content }
      else
        @graph.graph_membership_graphs.build
        @graph.graph_membership_nodes.build
        format.html { render action: "edit", :layout => !request.xhr? }
        format.json { render json: @graph.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /graphs/1
  # DELETE /graphs/1.json
  def destroy
    @graph = Graph.find(params[:id])
    @graph.destroy

    respond_to do |format|
      format.html { redirect_to graphs_url }
      format.json { head :no_content }
    end
  end
end
