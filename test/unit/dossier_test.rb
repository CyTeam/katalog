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

    dossier = Dossier.first
    
    updated_at = dossier.updated_at
    sleep 0.5
    dossier.title = "Neuer Titel"
    dossier.save
    
    assert dossier.updated_at > updated_at
  end
  
  test "updates parent timestamp" do
    dossier = dossiers(:first_important_zug)
    parent = dossier.find_parent
    
    updated_at = parent.updated_at
    sleep 0.5
    dossier.title = "Neuer Titel"
    dossier.save
    
    assert parent.updated_at > updated_at
  end
end
