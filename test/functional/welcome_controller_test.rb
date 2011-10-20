require 'test_helper'

class WelcomeControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  
  test "should get index" do
    get :index
    assert_response :success
  end
  
  test "if index has a text" do
    get :index
    
    assert_select 'h1.welcome'
    assert_select 'p.welcome'
  end
end
