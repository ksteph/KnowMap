Given /^a user exists with email "(.*?)" and password "(.*?)"$/ do |email, password|
  User.create(:email => email, :password => password)
end

Given /^I am an? (.*?) with email "(.*?)" and password "(.*?)"$/ do |role, email, password|
  user = User.create(:email => email, :password => password)
  if Role.find_by_name(role.titlecase) then
    user.roles << Role.find_by_name(role.titlecase)
  else
    user.roles << Role.create(:name => role.titlecase)
  end
  user.save
end

Given /^I have a user "(.*?)" with password "(.*?)" exists$/ do |arg1, arg2|
  pending # express the regexp above with the code you wish you had
end

Given /^I login with "(.*?)" and "(.*?)"$/ do |email, password|
  step "I am on the login page"
  step "I fill in \"Email\" with \"#{email}\""
  step "I fill in \"Password\" with \"#{password}\""
  step "I press \"Log in\""
  step "I should see \"#{email}\""
end

Given /^I sign up with email "(.*?)" and password "(.*?)"$/ do |email, password|
  step "I am on the signup page"
  step "I fill in \"Email\" with \"#{email}\""
  step "I fill in \"Password\" with \"#{password}\""
  step "I fill in \"Password confirmation\" with \"#{password}\""
  step "I press \"Sign up\""
end

Given /^I am not logged in$/ do
  step "I go to the logout page"
end

Given /^the role (.*?) exists$/ do |role|
  Role.create :name => role.titlecase
end

Given /^the graph "(.*?)" exists$/ do |name|
  Graph.create(name: name)
end

Given /^the node "(.*?)" exists$/ do |title|
  Node.create(title: title)
end

Then /^I print the page contents$/ do
  puts page.html
end

