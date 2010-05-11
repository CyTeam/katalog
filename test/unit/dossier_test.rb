require 'test_helper'

class DossierTest < ActiveSupport::TestCase
  # Import
  test "small import" do
    rows = Dossier.import_from_csv('test/fixtures/import/small.csv')
    assert_equal 48, Dossier.count
  end
end
