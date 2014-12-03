require 'rails_helper'

RSpec.describe Dossier, :type => :model do
  describe '#extract_tags' do
    it 'should split at most special characters' do
      tags = ['War. Peace', 'Ying and Yang', 'Mandela, Nelson', 'All (really) all; to say: every-thing.']
      Dossier.extract_tags(tags).should == %w(War Peace Ying and Yang Mandela Nelson All really all to say every thing)
    end

    it 'should drop numbers' do
      tags = ['1. World War (1914-1918)', "1'000'000 pieces", '3.5 pounds']
      Dossier.extract_tags(tags).should == %w(World War pieces pounds)
    end
  end
end
