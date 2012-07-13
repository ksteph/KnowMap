require 'spec_helper'

describe "actions/new" do
  before(:each) do
    assign(:action, stub_model(Action,
      :user_id => 1,
      :controller => "MyString",
      :action => "MyString"
    ).as_new_record)
  end

  it "renders new action form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => actions_path, :method => "post" do
      assert_select "input#action_user_id", :name => "action[user_id]"
      assert_select "input#action_controller", :name => "action[controller]"
      assert_select "input#action_action", :name => "action[action]"
    end
  end
end
