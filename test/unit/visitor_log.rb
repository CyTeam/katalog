require 'test_helper'

class VisitorLogTest < ActiveSupport::TestCase

  should "validate " do
    validate_presence_of(:user)
  end
end
