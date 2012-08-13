Feature: Log out
  In Order to keep my account safe
  I want to be able to log out
    
  @javascript @user @authentication
  Scenario: Log out of an account
    Given a user exists with email "test@test.com" and password "password"
    And I login with "test@test.com" and "password"
    When I follow "Log out"
    Then I should see "log in"
    And I should see "Sign up"
    And I should not see "test@test.com"
