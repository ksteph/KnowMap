require 'spec_helper'

describe "node_indices/new" do
  before(:each) do
    assign(:node_index, stub_model(NodeIndex,
      :course_id => 1,
      :node_id => 1,
      :index => 1
    ).as_new_record)
  end

  it "renders new node_index form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => node_indices_path, :method => "post" do
      assert_select "input#node_index_course_id", :name => "node_index[course_id]"
      assert_select "input#node_index_node_id", :name => "node_index[node_id]"
      assert_select "input#node_index_index", :name => "node_index[index]"
    end
  end
end
