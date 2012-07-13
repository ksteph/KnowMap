class NodesController < ApplicationController
  load_and_authorize_resource
  
  # GET /nodes
  # GET /nodes.json
  def index
    @nodes = Node.all
    
    Action.log :controller => params[:controller], :action => params[:action], :user => current_user

    respond_to do |format|
      format.html { render :layout => !request.xhr? } # index.html.erb
      format.json { render json: @nodes }
    end
  end

  # GET /nodes/1
  # GET /nodes/1.json
  def show
    @node = Node.find(params[:id])
    
    Action.log :controller => params[:controller], :action => params[:action], :target_id => params[:id], :user => current_user

    respond_to do |format|
      format.html { render :layout => !request.xhr? } # show.html.erb
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
    
    Action.log :controller => params[:controller], :action => params[:action], :user => current_user

    respond_to do |format|
      format.html { render :layout => !request.xhr? } # new.html.erb
      format.json { render json: @node }
    end
  end

  # GET /nodes/1/edit
  def edit
    @node = Node.find(params[:id])
    @node.related_edges_B.build
    @node.incoming_edges.build
    @node.outgoing_edges.build
    
    Action.log :controller => params[:controller], :action => params[:action], :target_id => params[:id], :user => current_user
    
    render :layout => !request.xhr?
  end

  # POST /nodes
  # POST /nodes.json
  def create
    @node = Node.new(params[:node])

    respond_to do |format|
      if @node.save
        Action.log :controller => params[:controller], :action => params[:action], :target_id => @node.id, :user => current_user
        format.html { redirect_to @node, notice: 'Node was successfully created.' }
        format.json { render json: @node, status: :created, location: @node }
      else
        @node.related_edges_B.build
        @node.incoming_edges.build
        @node.outgoing_edges.build
        format.html { render action: "new", :layout => !request.xhr? }
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
        Action.log :controller => params[:controller], :action => params[:action], :target_id => params[:id], :user => current_user
        format.html { redirect_to @node, notice: 'Node was successfully updated.' }
        format.json { head :no_content }
      else
        @node.related_edges_B.build
        @node.incoming_edges.build
        @node.outgoing_edges.build
        format.html { render action: "edit", :layout => !request.xhr? }
        format.json { render json: @node.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /nodes/1
  # DELETE /nodes/1.json
  def destroy
    @node = Node.find(params[:id])
    @node.destroy
    
    Action.log :controller => params[:controller], :action => params[:action], :target_id => params[:id], :user => current_user

    respond_to do |format|
      format.html { redirect_to nodes_url }
      format.json { head :no_content }
    end
  end
end
