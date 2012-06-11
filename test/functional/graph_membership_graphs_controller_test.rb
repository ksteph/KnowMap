require 'test_helper'

class GraphMembershipGraphsControllerTest < ActionController::TestCase
  setup do
    @graph_membership_graph = graph_membership_graphs(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:graph_membership_graphs)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create graph_membership_graph" do
    assert_difference('GraphMembershipGraph.count') do
      post :create, graph_membership_graph: { graph_id: @graph_membership_graph.graph_id, graph_id: @graph_membership_graph.graph_id }
    end

    assert_redirected_to graph_membership_graph_path(assigns(:graph_membership_graph))
  end

  test "should show graph_membership_graph" do
    get :show, id: @graph_membership_graph
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @graph_membership_graph
    assert_response :success
  end

  test "should update graph_membership_graph" do
    put :update, id: @graph_membership_graph, graph_membership_graph: { graph_id: @graph_membership_graph.graph_id, graph_id: @graph_membership_graph.graph_id }
    assert_redirected_to graph_membership_graph_path(assigns(:graph_membership_graph))
  end

  test "should destroy graph_membership_graph" do
    assert_difference('GraphMembershipGraph.count', -1) do
      delete :destroy, id: @graph_membership_graph
    end

    assert_redirected_to graph_membership_graphs_path
  end
end
