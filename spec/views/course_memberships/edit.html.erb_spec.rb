require 'spec_helper'

describe "course_memberships/edit" do
  before(:each) do
    @course_membership = assign(:course_membership, stub_model(CourseMembership,
      :course_id => 1,
      :user_id => 1,
      :role => 1
    ))
  end

  it "renders the edit course_membership form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => course_memberships_path(@course_membership), :method => "post" do
      assert_select "input#course_membership_course_id", :name => "course_membership[course_id]"
      assert_select "input#course_membership_user_id", :name => "course_membership[user_id]"
      assert_select "input#course_membership_role", :name => "course_membership[role]"
    end
  end
end
