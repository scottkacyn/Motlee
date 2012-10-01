require 'test_helper'

class CommentControllerTest < ActionController::TestCase
  test "should get comment_thread:references" do
    get :comment_thread:references
    assert_response :success
  end

  test "should get user:references" do
    get :user:references
    assert_response :success
  end

  test "should get body:string" do
    get :body:string
    assert_response :success
  end

end
