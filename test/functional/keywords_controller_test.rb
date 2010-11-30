require 'test_helper'

class KeywordsControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  
  test "should get keyword index" do
    get :index
    assert_response :success

    assert_not_nil assigns(:keywords)
    assert_equal assigns(:paginated_scope), Keyword
  end

  test "should get keyword search" do
    get :search, :search => {:text => 'test'}
    assert_response :success

    assert_equal "test", assigns(:query)
    assert_not_nil assigns(:keywords)
    assert_equal Keyword.where("name LIKE ?", "%test%"), assigns(:paginated_scope)
  end
end
