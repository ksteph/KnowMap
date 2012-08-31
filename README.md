KnowMap
========================

Knowledge Map interface

For something simple:
In the graphiz directory is the script
generate_graph.rb. It takes three parameters <concept csv file> <group csv file>
and <output header> and will output a .map file and .pdf of the graph. The .map
file is for graphiz and the .pdf file is the actual graph graphiz generates.

Example: ./generate_graph.rb concepts.csv groups.csv ../graphs/cs161

Requirements
------------
* PostgreSQL 8.4 or higher

Installation
------------
### Install PostgreSQL

    sudo apt-get install -y postgresql

### Change passsword for postgres username?

    sudo -u postgres psql postgres
    \password postgres

### Edit config/database.yml
Change the username and password to match your local configuration.

Testing
-------
### Cucumber
To run the cucumber tests, type:

    cucumber
