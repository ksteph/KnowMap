require 'spec_helper'

describe "actions/index" do
  before(:each) do
    assign(:actions, [
      stub_model(Action,
        :user_id => 1,
        :controller => "Controller",
        :action => "Action"
      ),
      stub_model(Action,
        :user_id => 1,
        :controller => "Controller",
        :action => "Action"
      )
    ])
  end

  it "renders a list of actions" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.to_s, :count => 2
    assert_select "tr>td", :text => "Controller".to_s, :count => 2
    assert_select "tr>td", :text => "Action".to_s, :count => 2
  end
end
