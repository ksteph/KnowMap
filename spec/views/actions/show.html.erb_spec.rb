require 'spec_helper'

describe "actions/show" do
  before(:each) do
    @action = assign(:action, stub_model(Action,
      :user_id => 1,
      :controller => "Controller",
      :action => "Action"
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/1/)
    rendered.should match(/Controller/)
    rendered.should match(/Action/)
  end
end
