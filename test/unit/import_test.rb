require 'test_helper'

class ImportTest < ActiveSupport::TestCase
  def assert_similar(expected, actual)
    klass = expected.class
    assert_kind_of klass, actual
    
    field_names = klass.content_columns.collect{|c| c.name}.reject{|name| ["created_at", "updated_at"].include?(name)}
    field_names.each {|field_name|
      assert_equal expected[field_name], actual[field_name], "Attribute '%s' of %s" % [field_name, actual.inspect]
    }
  end

  test "imports topics" do
    # Load fixtures as we destroy them, soon
    group_empty = dossiers('group_empty')
    group_7     = dossiers('group_7')
    
    first_topic = dossiers('first_topic')
    empty_topic = dossiers('empty_topic')
    
    topic_local   = dossiers('topic_local')
    topic_nowhere = dossiers('topic_nowhere')
    
    important_zug_topic = dossiers('important_zug_topic')
    simple_zug_topic    = dossiers('simple_zug_topic')
    empty_zug_topic     = dossiers('empty_zug_topic')
    
    # Cleanup database and import
    Dossier.destroy_all
    Dossier.import_from_csv(Rails.root.join('test/import/topics.csv'))
    
    # Test data
    assert_equal 2, TopicGroup.count
    assert_similar group_empty, TopicGroup.find_by_signature(8)
    assert_similar group_7, TopicGroup.find_by_signature(7)
    
    assert_equal 9, Topic.count
    assert_similar first_topic, Topic.find_by_signature(77)
    assert_similar empty_topic, Topic.find_by_signature(78)

    assert_equal 2, TopicGeo.count
    assert_similar topic_local, TopicGeo.find_by_signature('77.0')
    assert_similar topic_nowhere, TopicGeo.find_by_signature('77.9')

    assert_equal 3, TopicDossier.count
    assert_similar important_zug_topic, TopicDossier.find_by_signature('77.0.100')
    assert_similar simple_zug_topic, TopicDossier.find_by_signature('77.0.200')
    assert_similar empty_zug_topic, TopicDossier.find_by_signature('77.0.999')
  end

  test "imports dossiers" do
    # Load fixtures as we destroy them, soon
    group_7             = dossiers('group_7')
    first_topic         = dossiers('first_topic')
    topic_local         = dossiers('topic_local')
    important_zug_topic = dossiers('important_zug_topic')
    simple_zug_topic    = dossiers('simple_zug_topic')
    empty_zug_topic     = dossiers('empty_zug_topic')

    city_counsil           = dossiers('city_counsil')
    city_parties           = dossiers('city_parties')
    city_history           = dossiers('city_history')

    city_history_1900_1999 = containers('city_history_1900_1999')
    city_history_2000_2001 = containers('city_history_2000_2001')
    city_history_2002      = containers('city_history_2002')
    
    # Cleanup database and import
    Dossier.destroy_all
    rows = Dossier.import_from_csv(Rails.root.join('test/import/dossiers.csv'))

    # Test data
    assert_equal 18, Dossier.count

    # Fields
    assert_similar city_counsil, Dossier.find_by_title('City counsil')
    assert_similar city_parties, Dossier.find_by_title('City parties')
#    assert_similar city_history, Dossier.find_by_title('City history')
  end

  test "real data" do
    # Cleanup database and import
    Dossier.destroy_all
    rows = Dossier.import_from_csv(Rails.root.join('test/import/small.csv'))

    # Test data
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
  end
end
