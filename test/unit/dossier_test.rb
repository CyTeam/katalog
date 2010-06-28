require 'test_helper'

class DossierTest < ActiveSupport::TestCase
  # Import
  setup do
  end

  test "imports dossiers" do
    Dossier.delete_all
    
    rows = Dossier.import_from_csv(Rails.root.join('test/import/small.csv'))

    assert_equal 28, Dossier.count

    assert_equal 2, TopicGroup.count
    assert_equal 18, Topic.count
    assert_equal 1, TopicGeo.count
    assert_equal 12, TopicDossier.count

    # Fields
    dossier = Dossier.find_by_title("Kapitalismus grundsätzlich 2006 -")
    assert_equal "11.0.100", dossier.signature
    assert_equal "Kapitalismus grundsätzlich 2006 -", dossier.title
    assert_equal 1984, dossier.first_document_on.year
    assert_equal "DH", dossier.kind
  end
end
