Feature: Authentication
  In Order to
  As a
  I want to 
  
  Background:
    Given the graph "sample graph" exists
    And the node "sample node" exists
  
  ##
  #  graphs index
  ##

  @javascript  
  Scenario: Guest user on index graphs
    Given I am not logged in
    When I go to the graphs page
    Then I should not see "Access denied."

  @javascript  
  Scenario: Student user on index graphs
    Given I am a student with email "student@berkeley.edu" and password "password"
    And I login with "student@berkeley.edu" and "password"
    When I go to the graphs page
    Then I should not see "Access denied."

  @javascript  
  Scenario: Instructor user on index graphs
    Given I am an instructor with email "instructor@berkeley.edu" and password "password"
    And I login with "instructor@berkeley.edu" and "password"
    When I go to the graphs page
    Then I should not see "Access denied."

  @javascript  
  Scenario: Admin user on index graphs
    Given I am an admin with email "admin@berkeley.edu" and password "password"
    And I login with "admin@berkeley.edu" and "password"
    When I go to the graphs page
    Then I should not see "Access denied."

  @javascript  
  Scenario: Super user on index graphs
    Given I am a super with email "super@berkeley.edu" and password "password"
    And I login with "super@berkeley.edu" and "password"
    When I go to the graphs page
    Then I should not see "Access denied."
  
  ##
  #  show graph
  ##

  @javascript  
  Scenario: Guest show graph
    Given I am not logged in
    When I go to the "sample graph" graph
    Then I should not see "Access denied."

  @javascript  
  Scenario: Student user on show graph
    Given I am a student with email "student@berkeley.edu" and password "password"
    And I login with "student@berkeley.edu" and "password"
    When I go to the "sample graph" graph
    Then I should not see "Access denied."

  @javascript  
  Scenario: Instructor user on show graph
    Given I am an instructor with email "instructor@berkeley.edu" and password "password"
    And I login with "instructor@berkeley.edu" and "password"
    When I go to the "sample graph" graph
    Then I should not see "Access denied."

  @javascript  
  Scenario: Admin user on show graph
    Given I am an admin with email "admin@berkeley.edu" and password "password"
    And I login with "admin@berkeley.edu" and "password"
    When I go to the "sample graph" graph
    Then I should not see "Access denied."

  @javascript  
  Scenario: Super user on show graph
    Given I am a super with email "super@berkeley.edu" and password "password"
    And I login with "super@berkeley.edu" and "password"
    When I go to the "sample graph" graph
    Then I should not see "Access denied."
  
  ##
  #  new graph
  ##

  @javascript  
  Scenario: Guest new graph
    Given I am not logged in
    When I go to the new graph page
    Then I should see "Access denied."

  @javascript  
  Scenario: Student user on new graph
    Given I am a student with email "student@berkeley.edu" and password "password"
    And I login with "student@berkeley.edu" and "password"
    When I go to the new graph page
    Then I should not see "Access denied."

  @javascript  
  Scenario: Instructor user on new graph
    Given I am an instructor with email "instructor@berkeley.edu" and password "password"
    And I login with "instructor@berkeley.edu" and "password"
    When I go to the new graph page
    Then I should not see "Access denied."

  @javascript  
  Scenario: Admin user on new graph
    Given I am an admin with email "admin@berkeley.edu" and password "password"
    And I login with "admin@berkeley.edu" and "password"
    When I go to the new graph page
    Then I should not see "Access denied."

  @javascript  
  Scenario: Super user on new graph
    Given I am a super with email "super@berkeley.edu" and password "password"
    And I login with "super@berkeley.edu" and "password"
    When I go to the new graph page
    Then I should not see "Access denied."
  
  ##
  #  create graph
  ##

  @javascript  
  Scenario: Student user on create graph
    Given I am a student with email "student@berkeley.edu" and password "password"
    And I login with "student@berkeley.edu" and "password"
    When I go to the new graph page
    And I fill in "Name" with "student's new graph"
    And I press "Create Graph"
    Then I should see "Graph was successfully created."

  @javascript  
  Scenario: Instructor user on create graph
    Given I am an instructor with email "instructor@berkeley.edu" and password "password"
    And I login with "instructor@berkeley.edu" and "password"
    When I go to the new graph page
    And I fill in "Name" with "instructor's new graph"
    And I press "Create Graph"
    Then I should see "Graph was successfully created."

  @javascript  
  Scenario: Admin user on create graph
    Given I am an admin with email "admin@berkeley.edu" and password "password"
    And I login with "admin@berkeley.edu" and "password"
    When I go to the new graph page
    And I fill in "Name" with "admin's new graph"
    And I press "Create Graph"
    Then I should see "Graph was successfully created."

  @javascript  
  Scenario: Super user on create graph
    Given I am a super with email "super@berkeley.edu" and password "password"
    And I login with "super@berkeley.edu" and "password"
    When I go to the new graph page
    And I fill in "Name" with "super's new graph"
    And I press "Create Graph"
    Then I should see "Graph was successfully created."
  
  ##
  #  edit graph
  ##

  @javascript  
  Scenario: Guest edit graph
    Given I am not logged in
    When I go to the edit page for the "sample graph" graph
    Then I should see "Access denied."

  @javascript  
  Scenario: Student user on edit graph
    Given I am a student with email "student@berkeley.edu" and password "password"
    And I login with "student@berkeley.edu" and "password"
    When I go to the edit page for the "sample graph" graph
    Then I should not see "Access denied."

  @javascript  
  Scenario: Instructor user on edit graph
    Given I am an instructor with email "instructor@berkeley.edu" and password "password"
    And I login with "instructor@berkeley.edu" and "password"
    When I go to the edit page for the "sample graph" graph
    Then I should not see "Access denied."

  @javascript  
  Scenario: Admin user on edit graph
    Given I am an admin with email "admin@berkeley.edu" and password "password"
    And I login with "admin@berkeley.edu" and "password"
    When I go to the edit page for the "sample graph" graph
    Then I should not see "Access denied."

  @javascript  
  Scenario: Super user on edit graph
    Given I am a super with email "super@berkeley.edu" and password "password"
    And I login with "super@berkeley.edu" and "password"
    When I go to the edit page for the "sample graph" graph
    Then I should not see "Access denied."
  
  ##
  #  update graph
  ##

  @javascript  
  Scenario: Student user on update graph
    Given I am a student with email "student@berkeley.edu" and password "password"
    And I login with "student@berkeley.edu" and "password"
    When I go to the edit page for the "sample graph" graph
    And I press "Update Graph"
    Then I should not see "Access denied."

  @javascript  
  Scenario: Instructor user on update graph
    Given I am an instructor with email "instructor@berkeley.edu" and password "password"
    And I login with "instructor@berkeley.edu" and "password"
    When I go to the edit page for the "sample graph" graph
    And I press "Update Graph"
    Then I should not see "Access denied."

  @javascript  
  Scenario: Admin user on update graph
    Given I am an admin with email "admin@berkeley.edu" and password "password"
    And I login with "admin@berkeley.edu" and "password"
    When I go to the edit page for the "sample graph" graph
    And I press "Update Graph"
    Then I should not see "Access denied."

  @javascript  
  Scenario: Super user on update graph
    Given I am a super with email "super@berkeley.edu" and password "password"
    And I login with "super@berkeley.edu" and "password"
    When I go to the edit page for the "sample graph" graph
    And I press "Update Graph"
    Then I should not see "Access denied."
  
  ##
  #  delete graph
  ##

  @javascript  
  Scenario: Guest delete graph
    Given I am not logged in
    When I go to the asdf page
    Then I should see "Access denied."

  @javascript  
  Scenario: Student user on delete graph
    Given I am a student with email "student@berkeley.edu" and password "password"
    And I login with "student@berkeley.edu" and "password"
    When I go to the asdf page
    Then I should see "Access denied."

  @javascript  
  Scenario: Instructor user on delete graph
    Given I am an instructor with email "instructor@berkeley.edu" and password "password"
    And I login with "instructor@berkeley.edu" and "password"
    When I go to the asdf page
    Then I should see "Access denied."

  @javascript  
  Scenario: Admin user on delete graph
    Given I am an admin with email "admin@berkeley.edu" and password "password"
    And I login with "admin@berkeley.edu" and "password"
    When I go to the asdf page
    Then I should see "Access denied."

  @javascript  
  Scenario: Super user on delete graph
    Given I am a super with email "super@berkeley.edu" and password "password"
    And I login with "super@berkeley.edu" and "password"
    When I go to the asdf page
    Then I should not see "Access denied."
  
  ##
  #  nodes index
  ##

  @javascript  
  Scenario: Guest index nodes
    Given I am not logged in
    When I go to the nodes page
    Then I should not see "Access denied."

  @javascript  
  Scenario: Student user on index nodes
    Given I am a student with email "student@berkeley.edu" and password "password"
    And I login with "student@berkeley.edu" and "password"
    When I go to the nodes page
    Then I should not see "Access denied."

  @javascript  
  Scenario: Instructor user on index nodes
    Given I am an instructor with email "instructor@berkeley.edu" and password "password"
    And I login with "instructor@berkeley.edu" and "password"
    When I go to the nodes page
    Then I should not see "Access denied."

  @javascript  
  Scenario: Admin user on index nodes
    Given I am an admin with email "admin@berkeley.edu" and password "password"
    And I login with "admin@berkeley.edu" and "password"
    When I go to the nodes page
    Then I should not see "Access denied."

  @javascript  
  Scenario: Super user on index nodes
    Given I am a super with email "super@berkeley.edu" and password "password"
    And I login with "super@berkeley.edu" and "password"
    When I go to the nodes page
    Then I should not see "Access denied."
  
  ##
  #  show node
  ##

  @javascript  
  Scenario: Guest show node
    Given I am not logged in
    When I go to the "sample node" node
    Then I should not see "Access denied."

  @javascript  
  Scenario: Student user on show node
    Given I am a student with email "student@berkeley.edu" and password "password"
    And I login with "student@berkeley.edu" and "password"
    When I go to the "sample node" node
    Then I should not see "Access denied."

  @javascript  
  Scenario: Instructor user on show node
    Given I am an instructor with email "instructor@berkeley.edu" and password "password"
    And I login with "instructor@berkeley.edu" and "password"
    When I go to the "sample node" node
    Then I should not see "Access denied."

  @javascript  
  Scenario: Admin user on show node
    Given I am an admin with email "admin@berkeley.edu" and password "password"
    And I login with "admin@berkeley.edu" and "password"
    When I go to the "sample node" node
    Then I should not see "Access denied."

  @javascript  
  Scenario: Super user on show node
    Given I am a super with email "super@berkeley.edu" and password "password"
    And I login with "super@berkeley.edu" and "password"
    When I go to the "sample node" node
    Then I should not see "Access denied."
  
  ##
  #  new node
  ##

  @javascript  
  Scenario: Guest new node
    Given I am not logged in
    When I go to the new node page
    Then I should see "Access denied."

  @javascript  
  Scenario: Student user on new node
    Given I am a student with email "student@berkeley.edu" and password "password"
    And I login with "student@berkeley.edu" and "password"
    When I go to the new node page
    Then I should not see "Access denied."

  @javascript  
  Scenario: Instructor user on new node
    Given I am an instructor with email "instructor@berkeley.edu" and password "password"
    And I login with "instructor@berkeley.edu" and "password"
    When I go to the new node page
    Then I should not see "Access denied."

  @javascript  
  Scenario: Admin user on new node
    Given I am an admin with email "admin@berkeley.edu" and password "password"
    And I login with "admin@berkeley.edu" and "password"
    When I go to the new node page
    Then I should not see "Access denied."

  @javascript  
  Scenario: Super user on new node
    Given I am a super with email "super@berkeley.edu" and password "password"
    And I login with "super@berkeley.edu" and "password"
    When I go to the new node page
    Then I should not see "Access denied."
  
  ##
  #  create node
  ##

  @javascript  
  Scenario: Student user on create node
    Given I am a student with email "student@berkeley.edu" and password "password"
    And I login with "student@berkeley.edu" and "password"
    When I go to the new node page
    And I fill in "Title" with "student's new node"
    And I press "Create Node"
    Then I should see "Node was successfully created."

  @javascript  
  Scenario: Instructor user on create node
    Given I am an instructor with email "instructor@berkeley.edu" and password "password"
    And I login with "instructor@berkeley.edu" and "password"
    When I go to the new node page
    And I fill in "Title" with "instructor's new node"
    And I press "Create Node"
    Then I should see "Node was successfully created."

  @javascript  
  Scenario: Admin user on create node
    Given I am an admin with email "admin@berkeley.edu" and password "password"
    And I login with "admin@berkeley.edu" and "password"
    When I go to the new node page
    And I fill in "Title" with "admin's new node"
    And I press "Create Node"
    Then I should see "Node was successfully created."

  @javascript  
  Scenario: Super user on create node
    Given I am a super with email "super@berkeley.edu" and password "password"
    And I login with "super@berkeley.edu" and "password"
    When I go to the new node page
    And I fill in "Title" with "super's new node"
    And I press "Create Node"
    Then I should see "Node was successfully created."
  
  ##
  #  edit node
  ##

  @javascript  
  Scenario: Guest edit node
    Given I am not logged in
    When I go to the edit page for the "sample node" node
    Then I should see "Access denied."

  @javascript  
  Scenario: Student user on edit node
    Given I am a student with email "student@berkeley.edu" and password "password"
    And I login with "student@berkeley.edu" and "password"
    When I go to the edit page for the "sample node" node
    Then I should see "Access denied."

  @javascript  
  Scenario: Instructor user on edit node
    Given I am an instructor with email "instructor@berkeley.edu" and password "password"
    And I login with "instructor@berkeley.edu" and "password"
    When I go to the edit page for the "sample node" node
    Then I should see "Access denied."

  @javascript  
  Scenario: Admin user on edit node
    Given I am an admin with email "admin@berkeley.edu" and password "password"
    And I login with "admin@berkeley.edu" and "password"
    When I go to the edit page for the "sample node" node
    Then I should see "Access denied."

  @javascript  
  Scenario: Super user on edit node
    Given I am a super with email "super@berkeley.edu" and password "password"
    And I login with "super@berkeley.edu" and "password"
    When I go to the edit page for the "sample node" node
    Then I should not see "Access denied."
  
  ##
  #  update node
  ##
  
  @javascript  
  Scenario: Student user on update node
    Given I am a student with email "student@berkeley.edu" and password "password"
    And I login with "student@berkeley.edu" and "password"
    When I go to the edit page for the "sample node" node
    And I press "Update Node"
    Then I should see "Access denied."

  @javascript  
  Scenario: Instructor user on update node
    Given I am an instructor with email "instructor@berkeley.edu" and password "password"
    And I login with "instructor@berkeley.edu" and "password"
    When I go to the edit page for the "sample node" node
    And I press "Update Node"
    Then I should see "Access denied."

  @javascript  
  Scenario: Admin user on update node
    Given I am an admin with email "admin@berkeley.edu" and password "password"
    And I login with "admin@berkeley.edu" and "password"
    When I go to the edit page for the "sample node" node
    And I press "Update Node"
    Then I should see "Access denied."

  @javascript  
  Scenario: Super user on update node
    Given I am a super with email "super@berkeley.edu" and password "password"
    And I login with "super@berkeley.edu" and "password"
    When I go to the edit page for the "sample node" node
    And I press "Update Node"
    Then I should not see "Access denied."
  
  ##
  #  delete node
  ##

  @javascript  
  Scenario: Guest delete node
    Given I am not logged in
    When I go to the asdf page
    Then I should see "Access denied."

  @javascript  
  Scenario: Student user on delete node
    Given I am a student with email "student@berkeley.edu" and password "password"
    And I login with "student@berkeley.edu" and "password"
    When I go to the asdf page
    Then I should see "Access denied."

  @javascript  
  Scenario: Instructor user on delete node
    Given I am an instructor with email "instructor@berkeley.edu" and password "password"
    And I login with "instructor@berkeley.edu" and "password"
    When I go to the asdf page
    Then I should see "Access denied."

  @javascript  
  Scenario: Admin user on delete node
    Given I am an admin with email "admin@berkeley.edu" and password "password"
    And I login with "admin@berkeley.edu" and "password"
    When I go to the asdf page
    Then I should see "Access denied."

  @javascript  
  Scenario: Super user on delete node
    Given I am a super with email "super@berkeley.edu" and password "password"
    And I login with "super@berkeley.edu" and "password"
    When I go to the asdf page
    Then I should not see "Access denied."
