Given /^a user exists with email "(.*?)" and password "(.*?)"$/ do |email, password|
  User.create(:email => email, :password => password)
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

Given /^I have a user "(.*?)" with password "(.*?)" exists$/ do |arg1, arg2|
  pending # express the regexp above with the code you wish you had
end

Given /^the graph "(.*?)" exists$/ do |name|
  Graph.create(name: name)
end

Then /^I print the page contents$/ do
  puts page.html
end

