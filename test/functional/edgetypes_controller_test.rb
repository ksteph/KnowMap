require 'test_helper'

class EdgetypesControllerTest < ActionController::TestCase
  setup do
    @edgetype = edgetypes(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:edgetypes)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create edgetype" do
    assert_difference('Edgetype.count') do
      post :create, edgetype: { desc: @edgetype.desc, name: @edgetype.name }
    end

    assert_redirected_to edgetype_path(assigns(:edgetype))
  end

  test "should show edgetype" do
    get :show, id: @edgetype
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @edgetype
    assert_response :success
  end

  test "should update edgetype" do
    put :update, id: @edgetype, edgetype: { desc: @edgetype.desc, name: @edgetype.name }
    assert_redirected_to edgetype_path(assigns(:edgetype))
  end

  test "should destroy edgetype" do
    assert_difference('Edgetype.count', -1) do
      delete :destroy, id: @edgetype
    end

    assert_redirected_to edgetypes_path
  end
end
