class SearchController < ApplicationController
  def search
    params[:q] = nil if params[:q] == ""
    @graphs = params[:q] ? Graph.find(:all, :conditions => ['lower(name) LIKE lower(?)', "%#{params[:q]}%"]) : []
    @nodes =  params[:q] ? Node.find(:all, :conditions => ['lower(title) LIKE lower(?)', "%#{params[:q]}%"]) : []
    @total = @graphs.count + @nodes.count
    render :layout => !request.xhr?
  end
end
