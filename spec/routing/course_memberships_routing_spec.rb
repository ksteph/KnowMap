require "spec_helper"

describe CourseMembershipsController do
  describe "routing" do

    it "routes to #index" do
      get("/course_memberships").should route_to("course_memberships#index")
    end

    it "routes to #new" do
      get("/course_memberships/new").should route_to("course_memberships#new")
    end

    it "routes to #show" do
      get("/course_memberships/1").should route_to("course_memberships#show", :id => "1")
    end

    it "routes to #edit" do
      get("/course_memberships/1/edit").should route_to("course_memberships#edit", :id => "1")
    end

    it "routes to #create" do
      post("/course_memberships").should route_to("course_memberships#create")
    end

    it "routes to #update" do
      put("/course_memberships/1").should route_to("course_memberships#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/course_memberships/1").should route_to("course_memberships#destroy", :id => "1")
    end

  end
end
