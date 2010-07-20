require 'test_helper'

class IndexControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  
  test "should get keyword" do
    get :keyword
    assert_response :success

    assert_not_nil assigns(:index)
  end

  test "should get title" do
    get :title
    assert_response :success

    assert_not_nil assigns(:titles)
  end
end
