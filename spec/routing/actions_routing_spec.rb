require "spec_helper"

describe ActionsController do
  describe "routing" do

    it "routes to #index" do
      get("/actions").should route_to("actions#index")
    end

    it "routes to #new" do
      get("/actions/new").should route_to("actions#new")
    end

    it "routes to #show" do
      get("/actions/1").should route_to("actions#show", :id => "1")
    end

    it "routes to #edit" do
      get("/actions/1/edit").should route_to("actions#edit", :id => "1")
    end

    it "routes to #create" do
      post("/actions").should route_to("actions#create")
    end

    it "routes to #update" do
      put("/actions/1").should route_to("actions#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/actions/1").should route_to("actions#destroy", :id => "1")
    end

  end
end
