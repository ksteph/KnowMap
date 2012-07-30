require 'spec_helper'

describe "course_memberships/show" do
  before(:each) do
    @course_membership = assign(:course_membership, stub_model(CourseMembership,
      :course_id => 1,
      :user_id => 2,
      :role => 3
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
