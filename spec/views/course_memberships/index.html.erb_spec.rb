require 'spec_helper'

describe "course_memberships/index" do
  before(:each) do
    assign(:course_memberships, [
      stub_model(CourseMembership,
        :course_id => 1,
        :user_id => 2,
        :role => 3
      ),
      stub_model(CourseMembership,
        :course_id => 1,
        :user_id => 2,
        :role => 3
      )
    ])
  end

  it "renders a list of course_memberships" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.to_s, :count => 2
    assert_select "tr>td", :text => 2.to_s, :count => 2
    assert_select "tr>td", :text => 3.to_s, :count => 2
  end
end
