require 'test_helper'

class ContainerTest < ActiveSupport::TestCase
  setup do
    @container = Container.new
  end
  
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

  test "gracefully handle bad location assignment" do
    @container.location = "Nowhere"
    assert_equal nil, @container.location

    @container.location = "RI"
    assert_equal locations(:RI), @container.location
    
    @container.location = "Nowhere"
    assert_equal nil, @container.location
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
    assert_equal Date.parse('1910-01-01'), dossier.first_document_on
    assert_equal container_types(:DH), container.container_type
    assert_equal locations(:EG), container.location
  end

  # .period
  test ".period is empty if no dossier assigned" do
    container = Container.new(:dossier => nil)
    
    assert_equal '', container.period
  end
  
  test ".period is empty if no period assigned and no first_document_year set" do
    container = Factory.build(:container, :title => '')
    
    assert_equal '', container.period
  end
  
  test ".period" do
    container = Factory(:container, :title => '1989 -')
    
    assert_equal '1989 -', container.period
  end

  test ".period without period" do
    container = Factory.build(:container, :dossier => Factory.build(:dossier_since_1990))
    
    assert_equal '1990 -', container.period
  end

  # Caching
  test "adding a container updates dossier timestamp" do
    dossier = Factory(:dossier)
    updated_at = dossier.updated_at
    
    sleep(1)
    dossier.containers.create(Factory.attributes_for(:container_with_period, :location => Factory(:location), :container_type => Factory(:container_type)))
    dossier.reload
    
    assert dossier.updated_at > updated_at
  end

  test "removing a container updates dossier timestamp" do
    dossier = Factory(:dossier)
    dossier.containers.create(Factory.attributes_for(:container_with_period, :location => Factory(:location), :container_type => Factory(:container_type)))
    dossier.containers.create(Factory.attributes_for(:container_with_period, :location => Factory(:location), :container_type => Factory(:container_type)))
    updated_at = dossier.updated_at
    
    sleep(1)
    dossier.containers.last.destroy
    dossier.reload
    
    assert dossier.updated_at > updated_at
  end

  test "updating a container updates dossier timestamp" do
    dossier = Factory(:dossier)
    dossier.containers.create(Factory.attributes_for(:container_with_period, :location => Factory(:location), :container_type => Factory(:container_type)))
    dossier.containers.create(Factory.attributes_for(:container_with_period, :location => Factory(:location), :container_type => Factory(:container_type)))
    updated_at = dossier.updated_at
    
    sleep(1)
    container = dossier.containers.last
    container.title = "1990 - 1998"
    container.save
    dossier.reload
    
    assert dossier.updated_at > updated_at
  end
end
