require 'test_helper'

class KeywordTest < ActiveSupport::TestCase
  test "Keyword is an ActiveRecord" do
    Keyword.is_a?(ActiveRecord::Base)
  end
end
