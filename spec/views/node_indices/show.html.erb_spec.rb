require 'spec_helper'

describe "node_indices/show" do
  before(:each) do
    @node_index = assign(:node_index, stub_model(NodeIndex,
      :course_id => 1,
      :node_id => 2,
      :index => 3
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/1/)
    rendered.should match(/2/)
    rendered.should match(/3/)
  end
end
