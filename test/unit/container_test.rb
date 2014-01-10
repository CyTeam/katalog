require 'test_helper'

class ContainerTest < ActiveSupport::TestCase
  setup do
    @container = Container.new
  end

  test "dossier association" do
    assert_equal dossiers(:city_counsil), containers(:city_counsil).dossier
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

  # Caching
  test "adding a container updates dossier timestamp" do
    dossier = FactoryGirl.create(:dossier)
    updated_at = dossier.updated_at

    sleep(1)
    dossier.containers.create!(:period => '1999 - ', :location => FactoryGirl.create(:location), :container_type => FactoryGirl.create(:container_type))
    dossier.reload

    assert dossier.updated_at > updated_at
  end

  test "removing a container updates dossier timestamp" do
    dossier = FactoryGirl.create(:dossier)
    dossier.containers.create!(:period => '1999 - 2000', :location => FactoryGirl.create(:location), :container_type => FactoryGirl.create(:container_type))
    dossier.containers.create!(:period => '2000 - ', :location => FactoryGirl.create(:location), :container_type => FactoryGirl.create(:container_type))
    updated_at = dossier.updated_at

    sleep(1)
    dossier.containers.last.destroy
    dossier.reload

    assert dossier.updated_at > updated_at
  end

  test "updating a container updates dossier timestamp" do
    dossier = FactoryGirl.create(:dossier)
    dossier.containers.create!(:period => '1999 - 2000', :location => FactoryGirl.create(:location), :container_type => FactoryGirl.create(:container_type))
    dossier.containers.create!(:period => '2000 - ', :location => FactoryGirl.create(:location), :container_type => FactoryGirl.create(:container_type))
    updated_at = dossier.updated_at

    sleep(1)
    container = dossier.containers.last
    container.period = '2000 - 2001'
    container.save
    dossier.reload

    assert dossier.updated_at > updated_at
  end
end
