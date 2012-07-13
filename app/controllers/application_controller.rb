class ApplicationController < ActionController::Base
  protect_from_forgery
  
  def data
    @edges = Edge.all
    @nodes = Node.all
    render 'layouts/data.json.erb'
  end
end
