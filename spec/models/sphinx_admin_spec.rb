require 'rails_helper'

RSpec.describe SphinxAdmin, :type => :model do
  before :each do
    # Rspec 3 does not allow unverified doubles
    # Stub spacer as it should be defined by subclasses
    allow(SphinxAdmin).to receive(:spacer) { '=>' }

    # Stub out syncing to filesystem
    allow(SphinxAdmin).to receive(:sync_sphinx)
  end

  describe '.list=' do
    it 'should properly create records' do
      SphinxAdmin.list = "1 => one\n2 => two"

      expect(SphinxAdmin.where(from: 1, to: 'one')).to be_present
      expect(SphinxAdmin.where(from: 2, to: 'two')).to be_present
    end

    it 'should properly destroy records' do
      SphinxAdmin.list = "1 => one\n2 => two"
      SphinxAdmin.list = "1 => three\n3 => two"

      expect(SphinxAdmin.where(from: 1, to: 'one')).not_to be_present
      expect(SphinxAdmin.where(from: 2, to: 'two')).not_to be_present
    end

    it 'should accept multiple matches' do
      SphinxAdmin.list = "1 => one\n1 => uno"

      expect(SphinxAdmin.where(from: 1, to: 'one')).to be_present
      expect(SphinxAdmin.where(from: 1, to: 'uno')).to be_present
    end
  end

  describe '.extend_words' do
    it 'should add matching words' do
      SphinxAdmin.list = "1 => one\n0 => zero"

      expect(SphinxAdmin.extend_words(%w(0 one))).to match_array(%w(0 one 1 zero))
    end

    it 'should handle multiple matching words' do
      SphinxAdmin.list = "0 => zilch\n0 => zero"

      expect(SphinxAdmin.extend_words(%w(0 one))).to match_array(%w(0 one zilch zero))
    end
  end
end
