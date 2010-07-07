require 'test_helper'

class ContainerTest < ActiveSupport::TestCase
  test "dossier association" do
    assert_equal dossiers(:city_counsil), containers(:city_counsil).dossier
  end
  
  test "title" do
    assert_equal containers(:city_counsil).dossier.title, Dossier.truncate_title(containers(:city_counsil).title)
    assert_equal containers(:city_history_1900_1999).dossier.title, Dossier.truncate_title(containers(:city_history_1900_1999).title)
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

  test "import" do
    dossier = dossiers(:city_history)
    container_row = ['77.0.100', 'City history 2000 -', 0, '2001', 0, 0, 0, 0, 0, 'DH', 'EG']

    container = Container.import(container_row, dossier)
    
    assert_equal dossier, container.dossier
    assert_equal "City history 2000 -", container.title
    assert_equal Date.parse('2001-01-01'), container.first_document_on
    assert_equal container_types(:DH), container.container_type
    assert_equal locations(:EG), container.location
  end
end
