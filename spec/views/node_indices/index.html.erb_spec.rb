require 'spec_helper'

describe "node_indices/index" do
  before(:each) do
    assign(:node_indices, [
      stub_model(NodeIndex,
        :course_id => 1,
        :node_id => 2,
        :index => 3
      ),
      stub_model(NodeIndex,
        :course_id => 1,
        :node_id => 2,
        :index => 3
      )
    ])
  end

  it "renders a list of node_indices" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.to_s, :count => 2
    assert_select "tr>td", :text => 2.to_s, :count => 2
    assert_select "tr>td", :text => 3.to_s, :count => 2
  end
end
