# encoding: utf-8

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
  
  test "take first document from table" do
    assert_equal Date.parse('1910-01-01'), dossiers(:city_history).first_document_on
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
    assert_equal [[], [], []], Dossier.split_search_words('')
    assert_equal [['77.0.'], [], []], Dossier.split_search_words('77.0')
    assert_equal [['77.0.', '77.0.100', '77.0.10', '7', '77.0.1'], [], []], Dossier.split_search_words('77.0 77.0.100 77.0.10 7 77.0.1')

    assert_equal [[], ['test'], []], Dossier.split_search_words('test')
    assert_equal [[], ['test', 'new'], []], Dossier.split_search_words('test new')
    assert_equal [[], ['test', 'new'], []], Dossier.split_search_words('test, new')
    assert_equal [[], ['test', 'new'], []], Dossier.split_search_words('test. new')

    assert_equal [['77.0.'], ['test', 'new'], []], Dossier.split_search_words('test. 77.0, new')
  end
  
  test "search word extraction detects double quote sentences" do
    assert_equal [[], [], ['one']], Dossier.split_search_words('"one"')
    assert_equal [[], [], ['one two']], Dossier.split_search_words('"one two"')
    assert_equal [[], ['before', 'between', 'last'], ['one two', 'next, two']], Dossier.split_search_words('before, "one two" between "next, two" last')
  end
  
  test ".build_query adds * to signature searches" do
    assert_equal '@signature ("7*")', Dossier.build_query("7").strip
    assert_equal '@signature ("77.0.10*")', Dossier.build_query("77.0.10").strip
  end
  
  test ".build_query adds no * to short search words" do
    assert_match /[^*]a[^*]/, Dossier.build_query("nr a history").strip
  end
  
  test ".build_query adds trailing * to medium short search words" do
    assert_match /[^*]nr\*/, Dossier.build_query("nr a history").strip
  end
  
  test ".build_query adds surrounding * to non-short search words" do
    assert_match /\*history\*/, Dossier.build_query("nr as history").strip
  end
  
=begin
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
  
=end
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
  
#  test "keyword extraction respects brackets" do
#    keyword_list = ["One (et. al. and so on!) keyword", "(One. Two), (3. 4.5)", "And (Then. (We get bigger. Yes) Really.)"]
#
#    for keyword in keyword_list
#      assert Dossier.extract_keywords(keyword_list).include?(keyword), "Expected %s to include %s" % [Dossier.extract_keywords(keyword_list).inspect, keyword]
#    end
#  end
  
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
    assert_equal dossiers(:group_7, :first_topic, :topic_local, :important_zug_topic), dossiers(:city_history).parents
  end

  # Relations
  test "related_to is text" do
    assert_equal "City counsil", dossiers(:city_parties).related_to
    assert_equal "Worker Movement general; 77: City history", dossiers(:worker_movement_history).related_to
  end

  test "relations splits at ; and strips whitespaces" do
    assert_equal ["Worker Movement History", "Movements general"], dossiers(:worker_movement_general).relations
  end
  
  test "relation_titles drops leading topic indicator" do
    assert_equal ["Worker Movement general", "City history"], dossiers(:worker_movement_history).relation_titles
  end
  
  # Numbers
  test "creates number if no number for specified range" do
    @dossier.update_or_create_number(99, {:from => '2001-01-01', :to => '2002-12-31'})
    @dossier.save
    
    assert_equal 1, @dossier.numbers.count
    assert_equal 99, @dossier.document_count
    
    @dossier.update_or_create_number(100, {:from => '2001-01-01', :to => '2002-12-31'})
    @dossier.save
    
    assert_equal 1, @dossier.numbers.count
    assert_equal 199, @dossier.document_count
  end

  test "update_or_create_number understands nil range" do
    @dossier.update_or_create_number(99, {:from => nil, :to => '2002-12-31'})
    @dossier.save
    
    assert_equal 1, @dossier.numbers.count
    assert_equal 99, @dossier.document_count
    
    @dossier.update_or_create_number(100, {:from => nil, :to => '2002-12-31'})
    @dossier.save
    
    assert_equal 1, @dossier.numbers.count
    assert_equal 199, @dossier.document_count
  end

  test "update_or_create_number understands Date object" do
    @dossier.update_or_create_number(99, {:from => nil, :to => Date.new(2002, 12, 31)})
    @dossier.save
    
    assert_equal 1, @dossier.numbers.count
    assert_equal 99, @dossier.document_count
    
    @dossier.update_or_create_number(100, {:from => nil, :to => Date.new(2002, 12, 31)})
    @dossier.save
    
    assert_equal 1, @dossier.numbers.count
    assert_equal 199, @dossier.document_count
  
  end

  test "Assigning a number list ensures relevant number objects" do
    @dossier.dossier_number_list = "1990: 10\n1991: 20"
    
    assert_equal 2, @dossier.numbers.size
    assert_equal "1990: 10", @dossier.numbers.first.to_s
    assert_equal "1991: 20", @dossier.numbers.last.to_s
  end
  
  test "Re-assigning same dossier number list does not change objects" do
    list = @dossier.dossier_number_list
    objects = @dossier.numbers
    
    @dossier.dossier_number_list = list
    @dossier.save
    
    assert_equal objects, @dossier.numbers
  end
  
  test "Adding a dossier number using list does not change other objects" do
    list = @dossier.dossier_number_list
    objects = @dossier.numbers
    
    list += "\n15: 100"
    @dossier.dossier_number_list = list
    @dossier.save
    
    assert_equal objects, @dossier.numbers
  end
  
  test "Removing a number from list drops the object" do
    @dossier.dossier_number_list = "1999: 100"
    @dossier.dossier_number_list = "2000: 100"
    
    assert_equal 1, @dossier.numbers.size
    assert_equal "2000: 100", @dossier.numbers.to_s
  end
  
  test "Updating a number from list sets amount" do
    @dossier.dossier_number_list = "1999: 100"
    @dossier.dossier_number_list = "1999: 50"
    
    assert_equal 1, @dossier.numbers.size
    assert_equal "1999: 50", @dossier.numbers.to_s
  end
  
  test "document_count returns integer" do
    assert @dossier.document_count.is_a?(Integer)
  end

  test "#build_default_numbers adds default numbers" do
    dossier = Dossier.new
    dossier.build_default_numbers
    
    assert_equal DossierNumber.default_periods.count, dossier.numbers.size
  end
  
  test "#prepare_numbers add number for current year if not there yet" do
    dossier = Factory(:dossier)
    dossier.prepare_numbers

    assert_equal Date.today.year.to_s, dossier.numbers.last.period
  end

  test 'returns [] when called with nil as interval' do
    assert_equal Dossier.years(nil), []
  end

  test 'returns period of years with interval of 1 year' do
    assert_equal Dossier.years.count, 23
  end

  test 'returns period of years with interval of 5 years' do
    assert_equal Dossier.years(5).count, 6
  end

  test 'returns the right label of the persiod with interval of 5 years' do
    years = Dossier.years(5)
    assert_equal years.count, 6
    assert_equal years.first, 'vor 1990'
    assert_equal years[1], '1990 - 1994'
  end

  test 'returns year and the count of documents' do
    dossier = Factory(:dossier)
  end
  
  test 'description column gets empty string on save' do
    dossier = Factory.create(:dossier)
    
    assert_equal dossier.description, ''
  end

  test 'first_document_year handles blanks' do
    dossier = Factory.create(:dossier)
    
    dossier.first_document_year = nil
    assert_equal nil, dossier.first_document_year

    dossier.first_document_year = ''
    assert_equal nil, dossier.first_document_year
  end

  test 'first_document_year handles four digit years' do
    dossier = Factory.create(:dossier)
    
    dossier.first_document_year = '2011'
    assert_equal 2011, dossier.first_document_year
  end

  test 'first_document_year handles two digit years' do
    dossier = Factory.create(:dossier)
    
    dossier.first_document_year = '11'
    assert !(dossier.valid?)
  end
end
