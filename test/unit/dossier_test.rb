require 'test_helper'

class DossierTest < ActiveSupport::TestCase
  setup do
    @dossier = Dossier.new(:signature => "99.9.999", :title => 'Testing everything')
    @dossier.save
    
    Dossier.all.map{|dossier| dossier.update_tags; dossier.save}
  end
  
  test "to_s" do
    assert_equal "77.0.100: City counsil", dossiers(:city_counsil).to_s
    assert_equal "77.0.100: City history", dossiers(:city_history).to_s
  end

  test "signature gets stripped" do
    @dossier.signature = "99.7.888"
    assert_equal "99.7.888", @dossier.signature
    
    @dossier.signature = "66.7.888 "
    assert_equal "66.7.888", @dossier.signature
    
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
    
    assert_equal "Deiss, Josef (BR CVP 1999 - 2006)", Dossier.truncate_title("Deiss, Josef (BR CVP 1999 - 2006) 1989 - 2006")
    assert_equal "Hess, Peter (NR CVP 1983 - 2003)", Dossier.truncate_title("Hess, Peter (NR CVP 1983 - 2003) 2001")
    assert_equal "Hess, Peter (NR CVP 1983 - 2003)", Dossier.truncate_title("Hess, Peter (NR CVP 1983 - 2003) 2002 - ")
    
    assert_equal "Referenden gegen Teilrevision des Militärgesetzes (Abstimmung 2001)", Dossier.truncate_title("Referenden gegen Teilrevision des Militärgesetzes (Abstimmung 2001) 2000 - 2001")

    assert_equal "Terroranschlag, USA: 11. September 2001.", Dossier.truncate_title("Terroranschlag, USA: 11. September 2001. Okt. 2001")
    assert_equal "Terroranschlag, USA: 11. September 2001.", Dossier.truncate_title("Terroranschlag, USA: 11. September 2001. Nov. - Dez. 2001")
  end

  test "title truncation detects ordinal month names with spaces" do
    assert_equal "Terroranschlag, USA: 11. September 2001.", Dossier.truncate_title("Terroranschlag, USA: 11. September 2001. 12. 9. - 16. 9. 2001")
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

  test "search extraction detects signatures and words" do
    assert_equal [[], []], Dossier.split_search_words('')
    assert_equal [['77.0'], []], Dossier.split_search_words('77.0')
    assert_equal [['77.0', '77.0.100', '7', '77.0.1'], []], Dossier.split_search_words('77.0 77.0.100 7 77.0.1')

    assert_equal [[], ['test']], Dossier.split_search_words('test')
    assert_equal [[], ['test', 'new']], Dossier.split_search_words('test new')
    assert_equal [[], ['test', 'new']], Dossier.split_search_words('test, new')
    assert_equal [[], ['test', 'new']], Dossier.split_search_words('test. new')

    assert_equal [['77.0'], ['test', 'new']], Dossier.split_search_words('test. 77.0, new')
  end
  
  test "search word splitting drops double quote from words" do
    assert_equal ['one'], Dossier.split_search_words('"one"')
    assert_equal ['one', 'two'], Dossier.split_search_words('"one two"')
  end
  
  test "find by text" do
    keyword_list = ["City"]
    
    @dossier.keyword_list.add(Dossier.extract_keywords(keyword_list))
    @dossier.save
    
    assert_equal [dossiers(:simple_zug_topic), dossiers(:important_zug_topic), dossiers(:city_history), dossiers(:empty_zug_topic), dossiers(:city_counsil_notes), dossiers(:city_counsil), dossiers(:topic_local), dossiers(:city_parties), @dossier], Dossier.by_text('City')
  end
  
  test "find by text supports ANDs multiple words" do
    assert_equal [dossiers(:city_counsil_notes)], Dossier.by_text('counsil notes')
    assert_equal [dossiers(:city_counsil_notes)], Dossier.by_text('notes counsil')
  end
  
  test "find by text ANDs signature, keyword and title words" do
    assert_equal [dossiers(:city_counsil_notes)], Dossier.by_text('77 counsil notes')
  end
  
  test "find by text ORs signatures" do
    assert_same_set dossiers(:worker_movement_general, :worker_movement_history), Dossier.by_text('worker 11.0.100 11.0.500')
    assert_same_set dossiers(:worker_movement_general, :worker_movement_history), Dossier.by_text('11.0.5 worker 11.0.1')
  end
  
  test "find by text strips whitespace" do
    assert_equal [dossiers(:city_counsil_notes)], Dossier.by_text(' notes ')
  end
  
  test "find by text counts only distinct records" do
    assert_equal 8, Dossier.by_text('City').count
    assert_equal 8, Dossier.by_text('city').count
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

  test "tag extraction splits at most special characters" do
    tags = ["War. Peace", "Ying and Yang", "Mandela, Nelson", "All (really) all; to say: every-thing."]
    assert_equal 14, Dossier.extract_tags(tags).count
  end
  
  test "tag filter drops numbers" do
    tags = ["1. World War (1914-1918)", "1'000'000 pieces", "3.5 pounds"]
    assert_equal 4, Dossier.extract_tags(tags).count
  end

  test "tag filter drops month names" do
    tags = ["Jannick", "Feb", "Mai"]
    assert_equal ["Jannick"], Dossier.filter_tags(tags)
  end
  
  test "tag filter drops %" do
    tags = ["20% Gewinn"]
    assert_equal ["Gewinn"], Dossier.extract_tags(tags)
  end
  
  test "keywords are split only on dot" do
    keyword_list = ["Chomsky, Noam USA (1928 -)", "One. after. the other."]
    keywords = Dossier.extract_keywords(keyword_list)
    
    assert_equal 4, keywords.count
    assert keywords.include?("Chomsky, Noam USA (1928 -)")
    assert keywords.include?("the other")
  end
  
  test "keyword extraction respects common abbreviations" do
    keyword_list = ["betr. x", "x Kt. y", "Präs. (1900)"]
    
    for keyword in keyword_list
      assert Dossier.extract_keywords(keyword_list).include?(keyword)
    end
  end
  
  test "keyword extraction respects dates" do
    keyword_list = ["(Aug. 2000 - 2010)", "9. 9. 1997"]
    
    for keyword in keyword_list
      assert Dossier.extract_keywords(keyword_list).include?(keyword), "Expected %s to include %s" % [Dossier.extract_keywords(keyword_list).inspect, keyword]
    end
  end
  
  test "keyword extraction respects (middle) name initials" do
    keyword_list = ["Jan H. Rosenbaum", "K. Huber (1941-2000)"]
    
    for keyword in keyword_list
      assert Dossier.extract_keywords(keyword_list).include?(keyword), "Expected %s to include %s" % [Dossier.extract_keywords(keyword_list).inspect, keyword]
    end
  end
  
  test "keyword extraction only allows dot after single capital letter" do
    keyword_list = ["Fahnenbranche CH. Europa"]
    
    keywords = Dossier.extract_keywords(keyword_list)
    assert_equal 2, keywords.count
    assert keywords.include?('Fahnenbranche CH')
    assert keywords.include?('Europa')
  end
  
  test "import keywords adds to keyword and tag list" do
    keyword_row = []; keyword_row[13] = "Counsil"; keyword_row[14] = "Corruption"; keyword_row[15] = "Conflict";

    @dossier.import_keywords(keyword_row)
    assert_superset @dossier.keyword_list, ["Counsil", "Corruption", "Conflict"]
  end

  test "assigning keyword_list adds to global tag list" do
    # Add 2 keywords and 1 tag
    assert_difference('ActsAsTaggableOn::Tag.count', 2 + 1) do
      @dossier.keyword_list.add(['Word 1', 'Word 2', 'Word 2'])
      @dossier.save!
    end
    
    assert_equal [@dossier], Dossier.tagged_with('Word 1')
  end
  
  test "keyword supports dotted keyword" do
    @dossier.keyword_list.add(['Test. Dot'])
    @dossier.save!
    
    assert_equal 1, ActsAsTaggableOn::Tag.find_all_by_name('Test. Dot').count
    assert_equal [@dossier], Dossier.tagged_with(['Test. Dot'])
  end

  test "parent tree includes all parents" do
    assert_equal dossiers(:group_7, :first_topic, :topic_local), dossiers(:important_zug_topic).parent_tree
  end

  # Relations
  test "related_to is text" do
    assert_equal "City counsil", dossiers(:city_parties).related_to
    assert_equal "Worker Movement general; 77: City history", dossiers(:worker_movement_history).related_to
  end

  test "relation_titles splits at ; and strips whitespaces" do
    assert_equal ["Worker Movement History", "Movements general"], dossiers(:worker_movement_general).relation_titles
  end
  
  test "relation_titles drops leading topic indicator" do
    assert_equal ["Worker Movement general", "City history"], dossiers(:worker_movement_history).relation_titles
  end
end
