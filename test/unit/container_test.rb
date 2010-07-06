require 'test_helper'

class ContainerTest < ActiveSupport::TestCase
  test "dossier association" do
    assert_equal dossiers(:city_counsil), containers(:city_counsil).dossier
  end
end
