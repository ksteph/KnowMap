require 'spec_helper'

describe "NodeIndices" do
  describe "GET /node_indices" do
    it "works! (now write some real specs)" do
      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
      get node_indices_path
      response.status.should be(200)
    end
  end
end
