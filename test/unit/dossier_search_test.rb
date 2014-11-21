# encoding: utf-8

require 'test_helper'

class DossierTest < ActiveSupport::TestCase
  context '.split_search_words' do
    should 'detect empty search' do
      assert_equal [[], [], [], []], Dossier.split_search_words('')
      assert_equal [[], [], [], []], Dossier.split_search_words('   ')
    end

    should 'detect signatures' do
      assert_equal [['77.0.'], [], [], []], Dossier.split_search_words('77.0')
      assert_equal [['77.0.', '77.0.100', '77.0.10', '7', '77.0.1'], [], [], []], Dossier.split_search_words('77.0 77.0.100 77.0.10 7 77.0.1')
    end

    should 'detect words' do
      assert_equal [[], %w(test new), [], []], Dossier.split_search_words('test new')
      assert_equal [[], %w(test new), [], []], Dossier.split_search_words('test, new')
      assert_equal [[], %w(test new), [], []], Dossier.split_search_words('test. new')
    end

    should 'detect signatures and words' do
      assert_equal [['77.0.'], %w(test new), [], []], Dossier.split_search_words('test. 77.0, new')
      assert_equal [['77.0.1', '77.2.'], %w(haha bla), [], []], Dossier.split_search_words('haha. 77.0.1, bla 77.2')
    end

    should 'detect year' do
      assert_equal [[], ['1979'], [], []], Dossier.split_search_words('1979')
      assert_equal [[], ['2012'], [], []], Dossier.split_search_words('2012')
    end

    should 'detect double quote sentences' do
      assert_equal [[], [], ['one'], []], Dossier.split_search_words('"one"')
      assert_equal [[], [], ['one two'], []], Dossier.split_search_words('"one two"')
      assert_equal [[], %w(before between last), ['one two', 'next, two'], []], Dossier.split_search_words('before, "one two" between "next, two" last')
    end
  end

  context '.build_query' do
    should 'add * to signature searches' do
      assert_equal '@signature ("7*")', Dossier.build_query('7')
      assert_equal '@signature ("77.0.10*")', Dossier.build_query('77.0.10')
    end

    should 'add no * to short search words' do
      assert_match /[^*]a[^*]/, Dossier.build_query('nr a history')
    end

    should 'add trailing * to medium short search words' do
      assert_match /[^*]nr\*/, Dossier.build_query('nr a history')
    end

    should 'add surrounding * to non-short search words' do
      assert_match /\*history\*/, Dossier.build_query('nr as history')
    end

    should 'not include alternative word forms for words' do
      assert_no_match /Nationalrat/, Dossier.build_query('nr')
    end

    should 'build a signature range' do
      query = Dossier.build_query('7. - 77.0.200')
      assert_match '@signature (^77.0.100$)', query
      assert_match '@signature (^77.0.200$)', query
      assert_match '|', query
      assert_no_match '@signature (^77.0.999$)', query
    end
  end
end
