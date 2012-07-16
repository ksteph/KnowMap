Feature: User Tracking
  In Order to keep improve the knowledge map
  As an intructor
  I want to be able to track users' actions
  
  Background:
    Given the test database is seeded
    Given I am a student with email "asd@asd.com" and password "password"

  @javascript @t
  Scenario: User signs up
    Given I sign up with email "asdf@asdf.com" and password "password"
    And I login with "asdf@asdf.com" and "password"
    When I go to the actions page
    Then I should see "asdf@asdf.com signed up"
  
  @javascript
  Scenario: User logs in
    Given I login with "asd@asd.com" and "password"
    When I go to the actions page
    Then I should see "asd@asd.com logged in"
  
  @javascript
  Scenario: User logs out
    Given I login with "asd@asd.com" and "password"
    And I go to the logout page
    And I login with "asd@asd.com" and "password"
    When I go to the actions page
    Then I should see "asd@asd.com logged out"
  
  @javascript
  Scenario: User views the index page for all graphs
    Given I login with "asd@asd.com" and "password"
    And I go to the graphs page
    When I go to the actions page
    Then I should see "asd@asd.com viewed the index page for all graphs"
  
  @javascript
  Scenario: User visits new graph page
    Given I login with "asd@asd.com" and "password"
    And I go to the new graph page
    When I go to the actions page
    Then I should see "asd@asd.com viewed the new graph page"
  
  @javascript
  Scenario: User creates a new graph with errors
    Given I login with "asd@asd.com" and "password"
    And I go to the new graph page
    And I press "Create Graph"
    When I go to the actions page
    Then I should not see "asd@asd.com created a new graph"
  
  @javascript
  Scenario: User creates a new graph without errors
    Given I login with "asd@asd.com" and "password"
    And I go to the new graph page
    And I fill in "Name" with "my new graph"
    And I press "Create Graph"
    When I go to the actions page
    Then I should see "asd@asd.com created a new graph"
  
  @javascript
  Scenario: User views a graph
    Given I login with "asd@asd.com" and "password"
    Given the graph "Web security" exists
    And I go to the "Web security" graph
    When I go to the actions page
    Then I should see "asd@asd.com viewed Web security"
  
  @javascript
  Scenario: User visits the edit page for a graph
    Given I login with "asd@asd.com" and "password"
    Given the graph "Web security" exists
    And I go to the edit page for the "Web security" graph
    When I go to the actions page
    Then I should see "asd@asd.com viewed the edit page for Web security"
    
  @javascript
  Scenario: User updates a graph with errors
    Given I login with "asd@asd.com" and "password"
    Given the graph "Web security" exists
    And I go to the edit page for the "Web security" graph
    And I fill in "Name" with ""
    And I press "Update Graph"
    When I go to the actions page
    Then I should not see "asd@asd.com edited Web security"
  
  @javascript
  Scenario: User updates a graph without errors
    Given I login with "asd@asd.com" and "password"
    Given the graph "Web security" exists
    And I go to the edit page for the "Web security" graph
    And I fill in "Name" with "new graph name"
    And I press "Update Graph"
    When I go to the actions page
    Then I should see "asd@asd.com edited new graph name"
  
  @javascript
  Scenario: User deletes a graphs
    Given I login with "asd@asd.com" and "password"
