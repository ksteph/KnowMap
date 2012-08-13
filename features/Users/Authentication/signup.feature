Feature: Sign up for an account
  In Order to use the website
  I want to sign up for an account

  @javascript @user @authentication
  Scenario: Sign up for an account (happy path)
    Given I am on the signup page
    And I fill in "Email" with "test@test.com"
    And I fill in "Password" with "password"
    And I fill in "Password confirmation" with "password"
    When I press "Sign up"
    Then I should see "Signed up"

  @javascript @user @authentication
  Scenario: Sign up for an account without an email
    Given I am on the signup page
    And I fill in "Password" with "password"
    And I fill in "Password confirmation" with "password"
    When I press "Sign up"
    Then I should see "Email can't be blank"
    And I should not see "Signed up"

  @javascript @user @authentication
  Scenario: Sign up for an account without a password
    Given I am on the signup page
    And I fill in "Email" with "test@test.com"
    And I fill in "Password confirmation" with "password"
    When I press "Sign up"
    Then I should see "Password can't be blank"
    And I should not see "Signed up"

  @javascript @user @authentication
  Scenario: Sign up for an account without a password confirmation
    Given I am on the signup page
    And I fill in "Email" with "test@test.com"
    And I fill in "Password" with "password"
    When I press "Sign up"
    Then I should not see "Signed up"

  @javascript @user @authentication
  Scenario: Sign up for an account where password and password confirmation are different
    Given I am on the signup page
    And I fill in "Email" with "test@test.com"
    And I fill in "Password" with "password1"
    And I fill in "Password confirmation" with "password2"
    When I press "Sign up"
    Then I should see "Password doesn't match confirmation"
    And I should not see "Signed up"
