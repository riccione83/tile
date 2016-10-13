require 'test_helper'

class WorksControllerTest < ActionController::TestCase
  setup do
    @work = works(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:works)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create work" do
    assert_difference('Work.count') do
      post :create, work: { description: @work.description, location: @work.location, price_id: @work.price_id, title: @work.title, user_id: @work.user_id }
    end

    assert_redirected_to work_path(assigns(:work))
  end

  test "should show work" do
    get :show, id: @work
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @work
    assert_response :success
  end

  test "should update work" do
    patch :update, id: @work, work: { description: @work.description, location: @work.location, price_id: @work.price_id, title: @work.title, user_id: @work.user_id }
    assert_redirected_to work_path(assigns(:work))
  end

  test "should destroy work" do
    assert_difference('Work.count', -1) do
      delete :destroy, id: @work
    end

    assert_redirected_to works_path
  end
end
