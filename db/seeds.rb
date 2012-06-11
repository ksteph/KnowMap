# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

  dependent = Edgetype.create({ name: 'dependent', desc: 'A->B, A is a prereq for B'})
  related   = Edgetype.create({ name: 'related', desc: 'A<=>B, A and B are related'})
  
  n1 = Node.create({ title: 'TCP Header'})
  n2 = Node.create({ title: 'TCP Protocol Flow Chart'})
  n3 = Node.create({ title: 'TCP Connection Termination'})
  n4 = Node.create({ title: 'TCP Establish Connection'})
  n5 = Node.create({ title: 'TCP Flags'})
  
  Edge.create({ node_id_A: n1.id, node_id_B: n2.id, edgetype_id: dependent.id})
  Edge.create({ node_id_A: n1.id, node_id_B: n3.id, edgetype_id: dependent.id})
  Edge.create({ node_id_A: n1.id, node_id_B: n4.id, edgetype_id: dependent.id})
  Edge.create({ node_id_A: n1.id, node_id_B: n5.id, edgetype_id: related.id})
  
  g1 = Graph.create({ name: 'EE122'})
  g2 = Graph.create({ name: 'TCP'})
  n6 = Node.create({ title: 'UDP'})
  
  GraphMembershipGraph.create({ graph_id: g1.id, subgraph_id: g2.id})
  GraphMembershipNode.create({ graph_id: g1.id, node_id: n6.id})
  GraphMembershipNode.create({ graph_id: g2.id, node_id: n1.id})
  GraphMembershipNode.create({ graph_id: g2.id, node_id: n2.id})
  GraphMembershipNode.create({ graph_id: g2.id, node_id: n3.id})
  GraphMembershipNode.create({ graph_id: g2.id, node_id: n4.id})
  GraphMembershipNode.create({ graph_id: g2.id, node_id: n5.id})
