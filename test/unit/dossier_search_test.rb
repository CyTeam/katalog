# encoding: utf-8

require 'test_helper'

class DossierTest < ActiveSupport::TestCase
  test "search extraction detects empty search" do
    assert_equal [[], [], []], Dossier.split_search_words('')
    assert_equal [[], [], []], Dossier.split_search_words('   ')
  end

  test "search extraction detects signatures" do
    assert_equal [['77.0.'], [], []], Dossier.split_search_words('77.0')
    assert_equal [['77.0.', '77.0.100', '77.0.10', '7', '77.0.1'], [], []], Dossier.split_search_words('77.0 77.0.100 77.0.10 7 77.0.1')
  end

  test "search extraction detects words" do
    assert_equal [[], ['test', 'new'], []], Dossier.split_search_words('test new')
    assert_equal [[], ['test', 'new'], []], Dossier.split_search_words('test, new')
    assert_equal [[], ['test', 'new'], []], Dossier.split_search_words('test. new')
  end

  test "search extraction detects signatures and words" do
    assert_equal [['77.0.'], ['test', 'new'], []], Dossier.split_search_words('test. 77.0, new')
    assert_equal [['77.0.1', '77.2.'], ['haha', 'bla'], []], Dossier.split_search_words('haha. 77.0.1, bla 77.2')
  end

  test "search extraction detects year" do
    assert_equal [[], ['1979'], []], Dossier.split_search_words('1979')
    assert_equal [[], ['2012'], []], Dossier.split_search_words('2012')
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
  
end
