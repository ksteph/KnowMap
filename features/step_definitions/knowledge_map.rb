Given /^a user exists with email "(.*?)" and password "(.*?)"$/ do |email, password|
  User.create(:email => email, :password => password)
end

Given /^I login with "(.*?)" and "(.*?)"$/ do |arg1, arg2|
  step "I am on the login page"
  step "a user exists with email \"test@test.com\" and password \"password\""
  step "I fill in \"Email\" with \"test@test.com\""
  step "I fill in \"Password\" with \"password\""
  step "I press \"Log in\""
end

