require 'spec_helper'

describe SphinxAdmin do
  before :each do
    # Stub spacer as it should be defined by subclasses
    SphinxAdmin.stub(spacer: '=>')

    # Stub out syncing to filesystem
    SphinxAdmin.stub(:sync_sphinx)
  end

  describe '.list=' do
    it 'should properly create records' do
      SphinxAdmin.list = "1 => one\n2 => two"

      SphinxAdmin.where(from: 1, to: 'one').should be_present
      SphinxAdmin.where(from: 2, to: 'two').should be_present
    end

    it 'should properly destroy records' do
      SphinxAdmin.list = "1 => one\n2 => two"
      SphinxAdmin.list = "1 => three\n3 => two"

      SphinxAdmin.where(from: 1, to: 'one').should_not be_present
      SphinxAdmin.where(from: 2, to: 'two').should_not be_present
    end

    it 'should accept multiple matches' do
      SphinxAdmin.list = "1 => one\n1 => uno"

      SphinxAdmin.where(from: 1, to: 'one').should be_present
      SphinxAdmin.where(from: 1, to: 'uno').should be_present
    end
  end

  describe '.extend_words' do
    it 'should add matching words' do
      SphinxAdmin.list = "1 => one\n0 => zero"

      SphinxAdmin.extend_words(%w(0 one)).should =~ %w(0 one 1 zero)
    end

    it 'should handle multiple matching words' do
      SphinxAdmin.list = "0 => zilch\n0 => zero"

      SphinxAdmin.extend_words(%w(0 one)).should =~ %w(0 one zilch zero)
    end
  end
end
