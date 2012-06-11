require 'test_helper'

class EdgesControllerTest < ActionController::TestCase
  setup do
    @edge = edges(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:edges)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create edge" do
    assert_difference('Edge.count') do
      post :create, edge: { edgetype_id: @edge.edgetype_id, node_id_A: @edge.node_id_A, node_id_B: @edge.node_id_B }
    end

    assert_redirected_to edge_path(assigns(:edge))
  end

  test "should show edge" do
    get :show, id: @edge
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @edge
    assert_response :success
  end

  test "should update edge" do
    put :update, id: @edge, edge: { edgetype_id: @edge.edgetype_id, node_id_A: @edge.node_id_A, node_id_B: @edge.node_id_B }
    assert_redirected_to edge_path(assigns(:edge))
  end

  test "should destroy edge" do
    assert_difference('Edge.count', -1) do
      delete :destroy, id: @edge
    end

    assert_redirected_to edges_path
  end
end
