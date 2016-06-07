require 'test_helper'

class UserTicketsControllerTest < ActionController::TestCase
  setup do
    @user_ticket = user_tickets(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:user_tickets)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create user_ticket" do
    assert_difference('UserTicket.count') do
      post :create, user_ticket: {  }
    end

    assert_redirected_to user_ticket_path(assigns(:user_ticket))
  end

  test "should show user_ticket" do
    get :show, id: @user_ticket
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @user_ticket
    assert_response :success
  end

  test "should update user_ticket" do
    patch :update, id: @user_ticket, user_ticket: {  }
    assert_redirected_to user_ticket_path(assigns(:user_ticket))
  end

  test "should destroy user_ticket" do
    assert_difference('UserTicket.count', -1) do
      delete :destroy, id: @user_ticket
    end

    assert_redirected_to user_tickets_path
  end
end
