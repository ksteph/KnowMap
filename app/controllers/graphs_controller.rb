class GraphsController < ApplicationController
  load_and_authorize_resource
  # GET /graphs
  # GET /graphs.json
  def index
    if params[:id] then
      @graphs = Graph.find_all_by_id(params[:id].split(','), :include => [:subgraphs, :nodes])
    else
      @graphs = Graph.all :include => [:subgraphs, :nodes]
    end
    
    Action.log :controller => params[:controller], :action => params[:action], :user => current_user

    respond_to do |format|
      format.html { render :layout => !request.xhr? } # index.html.erb
      format.json #{ render json: @graphs }
    end
  end

  # GET /graphs/1
  # GET /graphs/1.json
  def show
    @graph = Graph.find(params[:id])
    
    Action.log :controller => params[:controller], :action => params[:action], :target_id => params[:id], :user => current_user

    respond_to do |format|
      format.html { render :layout => !request.xhr? } # show.html.erb
      format.json { render :partial => 'graph', :locals => {:graph => @graph} }
    end
  end

  # GET /graphs/new
  # GET /graphs/new.json
  def new
    @graph = Graph.new
    3.times { @graph.graph_membership_graphs.build }
    3.times { @graph.graph_membership_nodes.build }
    
    Action.log :controller => params[:controller], :action => params[:action], :user => current_user

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
    
    Action.log :controller => params[:controller], :action => params[:action], :target_id => params[:id], :user => current_user
    
    render :layout => !request.xhr?
  end

  # POST /graphs
  # POST /graphs.json
  def create
    @graph = Graph.new(params[:graph])

    respond_to do |format|
      if @graph.save
        Action.log :controller => params[:controller], :action => params[:action], :target_id => @graph.id, :user => current_user
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
        Action.log :controller => params[:controller], :action => params[:action], :target_id => params[:id], :user => current_user
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
    
    Action.log :controller => params[:controller], :action => params[:action], :target_id => params[:id], :user => current_user

    respond_to do |format|
      format.html { redirect_to :root, notice: 'Graph was successfully deleted.' }
      format.json { head :no_content }
    end
  end
  
  def groups_widget
    @graph = Graph.find(params[:graph_id])
    
    #Action.log :controller => params[:controller], :action => params[:action], :target_id => params[:id], :user => current_user

    render :partial => "groups_widget", :layout => false#, :layout => !request.xhr?
  end
  
  def versions
    @graph = Graph.find(params[:graph_id])
    @versions = @graph.versions
  end
  
  def version
    @graph = Graph.find(params[:graph_id])
    @version = @graph.versions.keep_if { |v| v.id === params[:version].to_i }
    @version = @version.first
  end
end
