require 'test_helper'

class ContainerTest < ActiveSupport::TestCase
  test "dossier association" do
    assert_equal dossiers(:city_counsil), containers(:city_counsil).dossier
  end
  
  test "title" do
    assert_equal containers(:city_counsil).dossier.title, containers(:city_counsil).title
  end
  
  test "to_s" do
    assert_equal "City counsil (DH@EG)", containers(:city_counsil).to_s
  end
end
