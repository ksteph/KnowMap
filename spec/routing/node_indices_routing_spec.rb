require "spec_helper"

describe NodeIndicesController do
  describe "routing" do

    it "routes to #index" do
      get("/node_indices").should route_to("node_indices#index")
    end

    it "routes to #new" do
      get("/node_indices/new").should route_to("node_indices#new")
    end

    it "routes to #show" do
      get("/node_indices/1").should route_to("node_indices#show", :id => "1")
    end

    it "routes to #edit" do
      get("/node_indices/1/edit").should route_to("node_indices#edit", :id => "1")
    end

    it "routes to #create" do
      post("/node_indices").should route_to("node_indices#create")
    end

    it "routes to #update" do
      put("/node_indices/1").should route_to("node_indices#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/node_indices/1").should route_to("node_indices#destroy", :id => "1")
    end

  end
end
