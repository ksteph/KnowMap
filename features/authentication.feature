Feature: Authentication
  In Order to keep track of my progress
  As a student
  I want to be able to log in
  
  Background:

  @javascript  
  Scenario: Sign up for an account
    Given I am on the signup page
    And I fill in "Email" with "test@test.com"
    And I fill in "Password" with "password"
    And I fill in "Password confirmation" with "password"
    When I press "Sign up"
    Then I should see "Signed up"
    
  @javascript  
  Scenario: Log in to an account
    Given I am on the login page
    And a user exists with email "test@test.com" and password "password"
    And I fill in "Email" with "test@test.com"
    And I fill in "Password" with "password"
    When I press "Log in"
    Then I should see "test@test.com"
    And I should see "Log out"
    And I should not see "log in"
    And I should not see "Sign up"
    
  @javascript
  Scenario: Log out of an account
    Given a user exists with email "test@test.com" and password "password"
    And I login with "test@test.com" and "password"
    When I follow "Log out"
    Then I should see "log in"
    And I should see "Sign up"
    And I should not see "test@test.com"
