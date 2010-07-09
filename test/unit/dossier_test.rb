require 'test_helper'

class DossierTest < ActiveSupport::TestCase
  setup do
    @dossier = Dossier.new
  end
  
  test "to_s" do
    assert_equal "77.0.100: City counsil", dossiers(:city_counsil).to_s
    assert_equal "77.0.100: City history", dossiers(:city_history).to_s
  end

  test "container association" do
    assert dossiers(:city_counsil).containers.include?(containers(:city_counsil))

    assert dossiers(:city_history).containers.include?(containers(:city_history_1900_1999))
    assert_equal 3, dossiers(:city_history).containers.count
  end

  test "title truncation" do
    for title in ["City counsil notes 2000 - 2001", "City counsil notes Jan. - Feb. 2002", "City counsil notes März 2002 - Feb. 2003", "City counsil notes 1. Apr. - 15. Mai 2003", "City counsil notes 16. Mai 2003 - 1. Apr. 2004", "City counsil notes 2005 -"]
      assert_equal "City counsil notes", Dossier.truncate_title(title)
    end
    
    for title in ["Olympic Games 2001 Preparations 1999 - 2000", "Olympic Games 2001 Preparations 2001"]
      assert_equal "Olympic Games 2001 Preparations", Dossier.truncate_title(title)
    end
  end

  test "first document calculation" do
    assert_equal containers(:city_history_1900_1999).first_document_on, dossiers(:city_history).first_document_on
  end
  
  test "dossier collects all container locations" do
    # TODO: using .reverse is not stable
    assert_equal Location.where(:code => ["RI", "EG"]).reverse, dossiers(:city_history).locations
  end

  test "find by signature" do
    # 3 actual dossiers, 1 topic
    assert_equal 3 + 1, Dossier.by_signature('77.0.100').count
  end

  test "find by location" do
    assert_equal 4, Dossier.by_location('EG').count
    assert_equal 1, Dossier.by_location('RI').count

    assert_equal 0, Dossier.by_location('Dummy').count
  end

  test "destroying dossier destroys it's containers" do
    assert_difference('Container.count', -3) do
      dossiers(:city_history).destroy
    end
  end

  test "destroying dossier destroys it's document numbers" do
    assert_difference('DossierNumber.count', -2) do
      dossiers(:city_history).destroy
    end
  end

  test "keyword delimited by dot (.)" do
    @dossier.keyword_list = "War. Peace. Ying and Yang. Mandela, Nelson. Love"
    
    assert_equal 5, @dossier.keyword_list.count
    assert @dossier.keyword_list.include?("Mandela, Nelson")
  end

  test "related_to is text" do
    assert_equal "City counsil", dossiers(:city_parties).related_to
  end
end
