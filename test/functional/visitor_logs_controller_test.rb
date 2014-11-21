require 'test_helper'

class VisitorLogsControllerTest  < ActionController::TestCase
  include Devise::TestHelpers

  setup do
    sign_in users(:editor)
  end

  test 'should get index' do
    get :index
    assert_response :success
  end
end
