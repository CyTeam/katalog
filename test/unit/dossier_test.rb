require 'test_helper'

class DossierTest < ActiveSupport::TestCase
  # Import
  setup do
    rows = Dossier.import_from_csv('test/fixtures/import/small.csv')
  end

  test "imports dossiers" do
    assert_equal 29, Dossier.count
  end

  test "imports topics" do
    assert_equal 2, TopicGroup.count
    assert_equal 5, Topic.count
  end
end
