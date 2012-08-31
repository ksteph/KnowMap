Feature: Log in
  In Order to use my account
  I want to be able to log in
    
  @javascript @user @authentication
  Scenario: Log into an account
    Given I am on the login page
    And a user exists with email "test@test.com" and password "password"
    And I fill in "Email" with "test@test.com"
    And I fill in "Password" with "password"
    When I press "Log in"
    Then I should see "test@test.com"
    And I should see "Log out"
    And I should not see "log in"
    And I should not see "Sign up"
