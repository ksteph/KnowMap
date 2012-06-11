require 'test_helper'

class GraphMembershipNodesControllerTest < ActionController::TestCase
  setup do
    @graph_membership_node = graph_membership_nodes(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:graph_membership_nodes)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create graph_membership_node" do
    assert_difference('GraphMembershipNode.count') do
      post :create, graph_membership_node: { graph_id: @graph_membership_node.graph_id, node_id: @graph_membership_node.node_id }
    end

    assert_redirected_to graph_membership_node_path(assigns(:graph_membership_node))
  end

  test "should show graph_membership_node" do
    get :show, id: @graph_membership_node
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @graph_membership_node
    assert_response :success
  end

  test "should update graph_membership_node" do
    put :update, id: @graph_membership_node, graph_membership_node: { graph_id: @graph_membership_node.graph_id, node_id: @graph_membership_node.node_id }
    assert_redirected_to graph_membership_node_path(assigns(:graph_membership_node))
  end

  test "should destroy graph_membership_node" do
    assert_difference('GraphMembershipNode.count', -1) do
      delete :destroy, id: @graph_membership_node
    end

    assert_redirected_to graph_membership_nodes_path
  end
end
