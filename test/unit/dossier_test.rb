# encoding: utf-8

require 'test_helper'

class DossierTest < ActiveSupport::TestCase
  setup do
    @dossier = Dossier.new(:signature => "99.9.999", :title => 'Testing everything')
    @dossier.save
    
    Dossier.all.map{|dossier| dossier.update_tags; dossier.save}
  end
  
  context "#to_s" do
    should "Include signature" do
      assert_match "11.1.111", FactoryGirl.build(:dossier).to_s
    end

    should "Include title" do
      assert_match "Dossier 1", FactoryGirl.build(:dossier).to_s
    end
  end

  context "#signature=" do
    should "strip spaces on assign" do
      @dossier.signature = " 66.7.888 "
      assert_equal "66.7.888", @dossier.signature
    end
  end
  
  context ".truncate_title" do
    should "Drop date ranges" do
      for title in ["City counsil notes 2000 - 2001", "City counsil notes Jan. - Feb. 2002", "City counsil notes März 2002 - Feb. 2003", "City counsil notes 1. Apr. - 15. Mai 2003", "City counsil notes 16. Mai 2003 - 1. Apr. 2004", "City counsil notes 2005 -"]
        assert_equal "City counsil notes", Dossier.truncate_title(title)
      end
    end

    should "leave dates in titles intact" do
      for title in ["Olympic Games 2001 Preparations 1999 - 2000", "Olympic Games 2001 Preparations 2001"]
        assert_equal "Olympic Games 2001 Preparations", Dossier.truncate_title(title)
      end
    end
    
    should "leave date ranges in titles intact" do
      assert_equal "Deiss, Josef (BR CVP 1999 - 2006)", Dossier.truncate_title("Deiss, Josef (BR CVP 1999 - 2006) 1989 - 2006")
      assert_equal "Hess, Peter (NR CVP 1983 - 2003)", Dossier.truncate_title("Hess, Peter (NR CVP 1983 - 2003) 2001")
      assert_equal "Hess, Peter (NR CVP 1983 - 2003)", Dossier.truncate_title("Hess, Peter (NR CVP 1983 - 2003) 2002 - ")

      assert_equal "Referenden gegen Teilrevision des Militärgesetzes (Abstimmung 2001)", Dossier.truncate_title("Referenden gegen Teilrevision des Militärgesetzes (Abstimmung 2001) 2000 - 2001")
    end
    
    should "leave non-last dates intact" do
      assert_equal "Terroranschlag, USA: 11. September 2001.", Dossier.truncate_title("Terroranschlag, USA: 11. September 2001. Okt. 2001")
      assert_equal "Terroranschlag, USA: 11. September 2001.", Dossier.truncate_title("Terroranschlag, USA: 11. September 2001. Nov. - Dez. 2001")
    end

    should "detect ordinal month names with spaces" do
      assert_equal "Terroranschlag, USA: 11. September 2001.", Dossier.truncate_title("Terroranschlag, USA: 11. September 2001. 12. 9. - 16. 9. 2001")
    end
  end

  context "#first_document_on" do
    should "take first document from table" do
      assert_equal Date.parse('1910-01-01'), FactoryGirl.build(:dossier, :first_document_on => '1910-01-01').first_document_on
    end
  end

  context "find scopes" do
    should "find by signature" do
      # 3 actual dossiers, 1 topic
      assert_equal 3 + 1, Dossier.by_signature('77.0.100').count
    end

    should "find by location" do
      assert_equal 4, Dossier.by_location('EG').count
      assert_equal 1, Dossier.by_location('RI').count

      assert_equal 0, Dossier.by_location('Dummy').count
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

  test 'concats the year prefix right' do
    nineties = Dossier.concat_year("90")
    new_age = Dossier.concat_year("09")
    assert_equal nineties, 1990
    assert_equal new_age, 2009
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

  test "dossier collects all container locations" do
    # TODO: using .reverse is not stable
    assert_equal Location.where(:code => ["RI", "EG"]).reverse, dossiers(:city_history).locations
  end

  context "containers association" do
    should "should accept attributes" do
      attributes = Factory.attributes_for(:dossier,
        :containers_attributes => { 1 => {:title => 'neu 2000', :container_type => ContainerType.first, :location => Location.first} }
      )
      assert_difference('Container.count', 1) do
        dossier = Dossier.create(attributes)
        assert dossier.persisted?
      end
    end

    should "be destroyed on dossier destroy" do
      assert_difference('Container.count', -3) do
        dossiers(:city_history).destroy
      end
    end
  end
end
