require 'test_helper'

class DossierTest < ActiveSupport::TestCase
  # Import
  setup do
    rows = Dossier.import_from_csv(Rails.root.join('test/import/small.csv'))
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
  
  test "updates timestamp" do
    dossier = Dossier.first
    
    updated_at = dossier.updated_at
    sleep 0.5
    dossier.title = "Neuer Titel"
    dossier.save
    
    assert dossier.updated_at > updated_at
  end
  
  test "updates parent timestamp" do
    dossier = Dossier.where("parent_id IS NOT NULL").first
    parent = dossier.parent
    
    updated_at = parent.updated_at
    sleep 0.5
    dossier.title = "Neuer Titel"
    dossier.save
    
    assert parent.updated_at > updated_at
  end
end
