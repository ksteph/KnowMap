Given /^a user exists with email "(.*?)" and password "(.*?)"$/ do |email, password|
  User.create({:email => email, :password => password}, :as => :new)
end

Given /^I am an? (.*?) with email "(.*?)" and password "(.*?)"$/ do |role, email, password|
  user = User.create(:email => email, :password => password)
  user.role = role.downcase
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

Given /^the test database is seeded$/ do
  load "#{Rails.root}/db/seeds.rb"
end

Given /^I change my password from "(.*?)" to "(.*?)"$/ do |arg1, arg2|
  step "I am on the change password page"
  step "I fill in \"Current password\" with \"#{arg1}\""
  step "I fill in \"New password\" with \"#{arg2}\""
  step "I fill in \"New password confirmation\" with \"#{arg2}\""
  step "I press \"Change password\""
end

Given /^I logout$/ do
  step "I go to the logout page"
end



