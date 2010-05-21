require 'test_helper'

class DossierTest < ActiveSupport::TestCase
  # Import
  setup do
    rows = Dossier.import_from_csv('test/fixtures/import/small.csv')
  end

  test "imports dossiers" do
    assert_equal 30, Dossier.count
  end

  test "imports topics" do
    assert_equal 2, TopicGroup.count
    assert_equal 18, Topic.count
    assert_equal 1, TopicGeo.count
    assert_equal 12, TopicDossier.count
  end
end
