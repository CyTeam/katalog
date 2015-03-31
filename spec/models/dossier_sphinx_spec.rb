require 'rails_helper'

RSpec.describe Dossier, :type => :model do
  describe '.split_search_words' do
    it 'should detect empty search' do
      expect(Dossier.split_search_words('')).to eq([[], [], []])
      expect(Dossier.split_search_words('   ')).to eq([[], [], []])
    end

    it 'should detect signatures' do
      expect(Dossier.split_search_words('77.0')).to eq([['77.0'], [], []])
      expect(Dossier.split_search_words('77.0 77.0.100 77.0.10 7 77.0.1')).to eq([['77.0', '77.0.100', '77.0.10', '7', '77.0.1'], [], []])
    end

    it 'should detect words' do
      expect(Dossier.split_search_words('test new')).to eq([[], %w(test new), []])
      expect(Dossier.split_search_words('test, new')).to eq([[], %w(test new), []])
      expect(Dossier.split_search_words('test. new')).to eq([[], %w(test new), []])
    end

    it 'should detect signatures and words' do
      expect(Dossier.split_search_words('test. 77.0, new')).to eq [['77.0'], %w(test new), []]
      expect(Dossier.split_search_words('haha. 77.0.1, bla 77.2')).to eq [['77.0.1', '77.2'], %w(haha bla), []]
    end

    it 'should detect year' do
      expect(Dossier.split_search_words('1979')).to eq [[], ['1979'], []]
      expect(Dossier.split_search_words('2012')).to eq [[], ['2012'], []]
    end

    it 'should detect double quote sentences' do
      expect(Dossier.split_search_words('"one"')).to eq [[], [], ['one']]
      expect(Dossier.split_search_words('"one two"')).to eq [[], [], ['one two']]
      expect(Dossier.split_search_words('before, "one two" between "next, two" last')).to eq [[], %w(before between last), ['one two', 'next, two']]
    end
  end

  context '.build_query' do
    it 'should add * to signature searches' do
      expect(Dossier.build_query('7')).to eq '@signature ("^7*")'
      expect(Dossier.build_query('77.0.10')).to eq '@signature ("^77.0.10*")'
    end

    it 'should add no * to short search words' do
      expect(Dossier.build_query('nr a history')).to match /[^*]a[^*]/
    end

    it 'should use literal and trailing * search for medium short search words' do
      expect(Dossier.build_query('nr a history')).to match(/"nr" \| "nr\*"/)
    end

    it 'should add surrounding * to non-short search words' do
      expect(Dossier.build_query('nr as history')).to match /\*history\*/
    end

    it 'should not include alternative word forms for words' do
      expect(Dossier.build_query('nr')).to_not match /Nationalrat/
    end

    it 'should build a signature range' do
      query = Dossier.build_query('7. - 77.0.200')
      expect(query).to include '@signature ("^77.0.200*")'
      expect(query).to include '|'
      expect(query).to_not match /@signature ("^77.0.999*")/
    end
  end

  context '.by_text' do
    it 'should work with & and +' do
      require 'thinking_sphinx/test'

      ThinkingSphinx::Test.run do
        expect { Dossier.by_text('&').count }.to_not raise_exception
        expect { Dossier.by_text('+').count }.to_not raise_exception
      end
    end
  end
end
