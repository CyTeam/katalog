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

  test "location assignment" do
    container = Container.new
    
    assert_nil container.location

    container.location = "RI"
    assert_equal locations(:RI), container.location
    
    container.location = "EG"
    assert_equal locations(:EG), container.location
    
    container.location = locations(:RI)
    assert_equal locations(:RI), container.location
  end

  test "container type assignment" do
    container = Container.new
    
    assert_nil container.container_type

    container.container_type = "DA"
    assert_equal container_types(:DA), container.container_type
    
    container.container_type = "DH"
    assert_equal container_types(:DH), container.container_type
    
    container.container_type = container_types(:DA)
    assert_equal container_types(:DA), container.container_type
  end
end
