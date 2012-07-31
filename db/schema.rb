# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120730215635) do

  create_table "actions", :force => true do |t|
    t.integer  "user_id"
    t.string   "controller"
    t.string   "action"
    t.integer  "target_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "course_memberships", :force => true do |t|
    t.integer  "course_id"
    t.integer  "user_id"
    t.integer  "role"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "courses", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "graph_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "edges", :force => true do |t|
    t.integer  "node_id_A",  :null => false
    t.integer  "node_id_B",  :null => false
    t.string   "type",       :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "edges", ["node_id_A", "node_id_B", "type"], :name => "index_edges_on_node_id_A_and_node_id_B_and_type", :unique => true
  add_index "edges", ["node_id_A"], :name => "index_edges_on_node_id_A"
  add_index "edges", ["node_id_B"], :name => "index_edges_on_node_id_B"
  add_index "edges", ["type"], :name => "index_edges_on_type"

  create_table "graph_membership_graphs", :force => true do |t|
    t.integer  "graph_id",    :null => false
    t.integer  "subgraph_id", :null => false
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "graph_membership_graphs", ["graph_id", "subgraph_id"], :name => "index_graph_membership_graphs_on_graph_id_and_subgraph_id", :unique => true
  add_index "graph_membership_graphs", ["graph_id"], :name => "index_graph_membership_graphs_on_graph_id"
  add_index "graph_membership_graphs", ["id"], :name => "index_graph_membership_graphs_on_id"
  add_index "graph_membership_graphs", ["subgraph_id"], :name => "index_graph_membership_graphs_on_subgraph_id"

  create_table "graph_membership_nodes", :force => true do |t|
    t.integer  "graph_id",   :null => false
    t.integer  "node_id",    :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "graph_membership_nodes", ["graph_id", "node_id"], :name => "index_graph_membership_nodes_on_graph_id_and_node_id", :unique => true
  add_index "graph_membership_nodes", ["graph_id"], :name => "index_graph_membership_nodes_on_graph_id"
  add_index "graph_membership_nodes", ["id"], :name => "index_graph_membership_nodes_on_id"
  add_index "graph_membership_nodes", ["node_id"], :name => "index_graph_membership_nodes_on_node_id"

  create_table "graphs", :force => true do |t|
    t.string   "name"
    t.text     "content"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "graphs", ["id"], :name => "index_graphs_on_id"

  create_table "node_indices", :force => true do |t|
    t.integer  "course_id"
    t.integer  "node_id"
    t.integer  "row"
    t.integer  "index"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "nodes", :force => true do |t|
    t.string   "title"
    t.text     "content"
    t.datetime "created_at",                  :null => false
    t.datetime "updated_at",                  :null => false
    t.float    "pos_x",      :default => 0.0
    t.float    "pos_y",      :default => 0.0
  end

  add_index "nodes", ["id"], :name => "index_nodes_on_id"

  create_table "roles", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "roles_users", :force => true do |t|
    t.integer "role_id"
    t.integer "user_id"
  end

  create_table "users", :force => true do |t|
    t.string   "email"
    t.string   "password_hash"
    t.string   "password_salt"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.string   "first"
    t.string   "last"
  end

end
