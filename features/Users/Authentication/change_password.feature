Feature: Change password
  In Order to maintain my account
  I want to be able to change my password
  
  Background:
    Given a user exists with email "test@test.com" and password "password"
    And I login with "test@test.com" and "password"
    
  @javascript @user @authentication
  Scenario: Change password
    Given I am on the change password page
    And I fill in "Current password" with "password"
    And I fill in "New password" with "password2"
    And I fill in "New password confirmation" with "password2"
    When I press "Change password"
    Then I should see "Password successfully updated."
    
  @javascript @user @authentication
  Scenario: Using password after changing it
    Given I change my password from "password" to "password2"
    And I logout
    And I login with "test@test.com" and "password2"
    Then I should see "test@test.com"
    And I should see "Log out"
    And I should not see "log in"
    And I should not see "Sign up"
    
  @javascript @user @authentication
  Scenario: Change password with incorrect old password
    Given I am on the change password page
    And I fill in "Current password" with "wrong_password"
    And I fill in "New password" with "password2"
    And I fill in "New password confirmation" with "password2"
    When I press "Change password"
    Then I should see "The current password you entered is invalid."
    And I should not see "Password successfully updated."
    
  @javascript @user @authentication
  Scenario: Change password with non matching new password
    Given I am on the change password page
    And I fill in "Current password" with "password"
    And I fill in "New password" with "password2"
    And I fill in "New password confirmation" with "password3"
    When I press "Change password"
    Then I should see "Password doesn't match confirmation"
    And I should not see "Password successfully updated."
