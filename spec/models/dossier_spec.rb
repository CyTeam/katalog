require 'rails_helper'

RSpec.describe Dossier, :type => :model do
  describe '#to_s' do
    it 'should include signature' do
      expect(FactoryGirl.build(:dossier).to_s).to match(/11\.1\.111/)
    end

    it 'should include title' do
      expect(FactoryGirl.build(:dossier).to_s).to match(/Dossier 1/)
    end
  end

  describe '#signature=' do
    let(:dossier) { FactoryGirl.build(:dossier) }
    it 'should strip spaces on assign' do
      dossier.signature = ' 66.7.888 '
      expect(dossier.signature).to eq('66.7.888')
    end
  end

  describe '#destroy' do
    it "should destroy it's document numbers" do
      dossier = FactoryGirl.create(:dossier)
      dossier.dossier_number_list = "1900 - 2000\n2001 -"
      dossier.save

      expect do
        dossier.destroy
      end.to change {
        DossierNumber.count
      }.by(-2)
    end
  end

  describe '#filter_tags' do
    it 'should drop month names' do
      tags = %w(Jannick Feb Mai)
      expect(Dossier.filter_tags(tags)).to eq(['Jannick'])
    end

    it 'tag filter drops %' do
      tags = ['20% Gewinn']
      expect(Dossier.extract_tags(tags)).to eq(['Gewinn'])
    end
  end

  # Relations
  # =========
  describe 'after_save hook' do
    it 'should touch all related dossiers' do
      counsil = FactoryGirl.create(:dossier, title: 'City counsil')
      history = FactoryGirl.create(:dossier, title: 'City history')
      dossier = FactoryGirl.build(:dossier, related_to: 'City counsil; City history')

      counsil_timestamp = counsil.updated_at
      history_timestamp = counsil.updated_at

      dossier.save!

      expect(history.reload.updated_at).not_to eq(history_timestamp)
      expect(counsil.reload.updated_at).not_to eq(counsil_timestamp)
    end
  end

  describe 'before_save hook' do
    it 'should keep relations intact on renames' do
      counsil = FactoryGirl.create(:dossier, title: 'City counsil')
      history = FactoryGirl.create(:dossier, title: 'City history')
      dossier = FactoryGirl.create(:dossier, related_to: 'City counsil; City history')

      related_dossiers = dossier.related_dossiers
      counsil.update_attributes(title: 'City counsil (new)')
      expect(dossier.reload.related_dossiers).to match(related_dossiers)
    end
  end

  describe '#related_to' do
    it 'should be text' do
      dossier = FactoryGirl.build(:dossier, related_to: 'City counsil; City history')

      expect(dossier.related_to).to eq('City counsil; City history')
    end

    it 'should persist more than 256 characters' do
      long_text = 'A' * 500
      dossier = FactoryGirl.create(:dossier, related_to: long_text)

      dossier.reload
      expect(dossier.related_to).to eq(long_text)
    end
  end

  describe '#relations' do
    it 'should return empty array when nil' do
      dossier = FactoryGirl.build(:dossier, related_to: nil)

      expect(dossier.relations).to be_empty
    end

    it 'should return empty array when blank' do
      dossier = FactoryGirl.build(:dossier, related_to: '  ')

      expect(dossier.relations).to be_empty
    end

    it 'should split at ;' do
      dossier = FactoryGirl.build(:dossier, related_to: 'City counsil; City history')

      expect(dossier.relations).to match_array(['City counsil', 'City history'])
    end

    it 'should strip whitespaces' do
      dossier = FactoryGirl.build(:dossier, related_to: ' City counsil; City history ')

      expect(dossier.relations).to match_array(['City counsil', 'City history'])
    end

    it 'should drop empty relations' do
      dossier = FactoryGirl.build(:dossier, related_to: '; City counsil;; City history ')

      expect(dossier.relations).to match_array(['City counsil', 'City history'])
    end
  end

  describe '#related_dossiers' do
    it 'should return dossiers with exact matches' do
      counsil = FactoryGirl.create(:dossier, title: 'City counsil')
      history = FactoryGirl.create(:dossier, title: 'City history')
      dossier = FactoryGirl.build(:dossier, related_to: 'City counsil; City history')

      expect(dossier.related_dossiers).to match_array([counsil, history])
    end

    it 'should not return dossiers with partial matches' do
      counsil = FactoryGirl.create(:dossier, title: 'City')
      history = FactoryGirl.create(:dossier, title: 'City history book')
      dossier = FactoryGirl.build(:dossier, related_to: 'City counsil; City history')

      expect(dossier.related_dossiers).to be_empty
    end

    it 'should return dossiers linking back' do
      counsil = FactoryGirl.create(:dossier, title: 'City counsil')
      history = FactoryGirl.create(:dossier, title: 'City history')
      dossier = FactoryGirl.create(:dossier, related_to: 'City counsil; City history')

      expect(counsil.related_dossiers).to match_array([dossier])
      expect(history.related_dossiers).to match_array([dossier])
    end
  end

  describe '#back_related_dossiers' do
    it 'should return empty list if title is blank' do
      dossier = FactoryGirl.build(:dossier, title: '')

      expect(dossier.back_related_dossiers).to be_empty
    end

    it 'should return dossiers with exact matches' do
      counsil = FactoryGirl.create(:dossier, title: 'City counsil')
      history = FactoryGirl.create(:dossier, title: 'City history')
      dossier = FactoryGirl.create(:dossier, related_to: 'City counsil; City history')
      second = FactoryGirl.create(:dossier, related_to: 'City counsil')

      expect(history.back_related_dossiers).to match_array([dossier])
      expect(counsil.back_related_dossiers).to match_array([dossier, second])
    end

    it 'should not return dossiers with partial matches' do
      counsil = FactoryGirl.create(:dossier, title: 'City')
      history = FactoryGirl.create(:dossier, title: 'City history book')
      dossier = FactoryGirl.create(:dossier, related_to: 'City counsil; City history')

      expect(counsil.back_related_dossiers).to be_empty
      expect(history.back_related_dossiers).to be_empty
    end
  end

  describe '#back_relations' do
    it 'should return empty list if title is blank' do
      dossier = FactoryGirl.build(:dossier, title: '')

      expect(dossier.back_relations).to be_empty
    end

    it 'should return dossiers with exact matches' do
      counsil = FactoryGirl.create(:dossier, title: 'City counsil')
      history = FactoryGirl.create(:dossier, title: 'City history')
      dossier = FactoryGirl.create(:dossier, related_to: 'City counsil; City history')
      second = FactoryGirl.create(:dossier, related_to: 'City counsil')

      expect(history.back_relations).to match_array([dossier.title])
      expect(counsil.back_relations).to match_array([dossier.title, second.title])
    end

    it 'should not return dossiers with partial matches' do
      counsil = FactoryGirl.create(:dossier, title: 'City')
      history = FactoryGirl.create(:dossier, title: 'City history book')
      dossier = FactoryGirl.create(:dossier, related_to: 'City counsil; City history')

      expect(counsil.back_relations).to be_empty
      expect(history.back_relations).to be_empty
    end
  end

  describe '.with_dangling_relations' do
    it 'should return dossiers with relation with no exact matches' do
      counsil = FactoryGirl.create(:dossier, title: 'City counsil')
      history = FactoryGirl.create(:dossier, title: 'City history book')
      dossier = FactoryGirl.create(:dossier, related_to: 'City counsil; City history')

      expect(Dossier.with_dangling_relations).to eq([dossier])
    end

    it 'should not return dossiers where all relations have matches' do
      counsil = FactoryGirl.create(:dossier, title: 'City counsil')
      history = FactoryGirl.create(:dossier, title: 'City history')
      dossier = FactoryGirl.create(:dossier, related_to: 'City counsil; City history')

      expect(Dossier.with_dangling_relations).to eq([])
    end
  end
end
