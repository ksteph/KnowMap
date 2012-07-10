require 'spec_helper'

describe "actions/edit" do
  before(:each) do
    @action = assign(:action, stub_model(Action,
      :user_id => 1,
      :controller => "MyString",
      :action => "MyString"
    ))
  end

  it "renders the edit action form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => actions_path(@action), :method => "post" do
      assert_select "input#action_user_id", :name => "action[user_id]"
      assert_select "input#action_controller", :name => "action[controller]"
      assert_select "input#action_action", :name => "action[action]"
    end
  end
end
