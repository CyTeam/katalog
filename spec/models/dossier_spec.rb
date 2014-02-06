require 'spec_helper'

describe Dossier do
  describe "#to_s" do
    it "should include signature" do
      FactoryGirl.build(:dossier).to_s.should =~ /11\.1\.111/
    end

    it "should include title" do
      FactoryGirl.build(:dossier).to_s.should =~ /Dossier 1/
    end
  end

  describe "#signature=" do
    let(:dossier) { FactoryGirl.build(:dossier) }
    it "should strip spaces on assign" do
      dossier.signature = " 66.7.888 "
      dossier.signature.should == "66.7.888"
    end
  end

  describe "#destroy" do
    it "should destroy it's document numbers" do
      dossier = FactoryGirl.create(:dossier)
      dossier.dossier_number_list = "1900 - 2000\n2001 -"
      dossier.save

      expect {
        dossier.destroy
      }.to change {
       DossierNumber.count
      }.by(-2)
    end
  end

  describe "#filter_tags" do
    it "should drop month names" do
      tags = ["Jannick", "Feb", "Mai"]
      Dossier.filter_tags(tags).should == ["Jannick"]
    end

    it "tag filter drops %" do
      tags = ["20% Gewinn"]
      Dossier.extract_tags(tags).should == ["Gewinn"]
    end
  end

  # Relations
  # =========
  describe "after_save hook" do
    it "should touch all related dossiers" do
      counsil = FactoryGirl.create(:dossier, :title => 'City counsil')
      history = FactoryGirl.create(:dossier, :title => 'City history')
      dossier = FactoryGirl.build(:dossier, :related_to => 'City counsil; City history')

      counsil_timestamp = counsil.updated_at
      history_timestamp = counsil.updated_at

      dossier.save!

      history.reload.updated_at.should_not == history_timestamp
      counsil.reload.updated_at.should_not == counsil_timestamp
    end
  end

  describe "before_save hook" do
    it "should keep relations intact on renames" do
      counsil = FactoryGirl.create(:dossier, :title => 'City counsil')
      history = FactoryGirl.create(:dossier, :title => 'City history')
      dossier = FactoryGirl.create(:dossier, :related_to => 'City counsil; City history')

      related_dossiers = dossier.related_dossiers
      counsil.update_attributes(:title => 'City counsil (new)')
      dossier.reload.related_dossiers.should =~ related_dossiers
    end
  end

  describe "#related_to" do
    it "should be text" do
      dossier = FactoryGirl.build(:dossier, :related_to => 'City counsil; City history')

      dossier.related_to.should == 'City counsil; City history'
    end

    it "should persist more than 256 characters" do
      long_text = "A" * 500
      dossier = FactoryGirl.create(:dossier, :related_to => long_text)

      dossier.reload
      dossier.related_to.should == long_text
    end
  end

  describe "#relations" do
    it "should return empty array when nil" do
      dossier = FactoryGirl.build(:dossier, :related_to => nil)

      dossier.relations.should be_empty
    end

    it "should return empty array when blank" do
      dossier = FactoryGirl.build(:dossier, :related_to => '  ')

      dossier.relations.should be_empty
    end

    it "should split at ;" do
      dossier = FactoryGirl.build(:dossier, :related_to => 'City counsil; City history')

      dossier.relations.should =~ ['City counsil', 'City history']
    end

    it "should strip whitespaces" do
      dossier = FactoryGirl.build(:dossier, :related_to => ' City counsil; City history ')

      dossier.relations.should =~ ['City counsil', 'City history']
    end

    it "should drop empty relations" do
      dossier = FactoryGirl.build(:dossier, :related_to => '; City counsil;; City history ')

      dossier.relations.should =~ ['City counsil', 'City history']
    end
  end

  describe "#related_dossiers" do
    it "should return dossiers with exact matches" do
      counsil = FactoryGirl.create(:dossier, :title => 'City counsil')
      history = FactoryGirl.create(:dossier, :title => 'City history')
      dossier = FactoryGirl.build(:dossier, :related_to => 'City counsil; City history')

      dossier.related_dossiers.should =~ [counsil, history]
    end

    it "should not return dossiers with partial matches" do
      counsil = FactoryGirl.create(:dossier, :title => 'City')
      history = FactoryGirl.create(:dossier, :title => 'City history book')
      dossier = FactoryGirl.build(:dossier, :related_to => 'City counsil; City history')

      dossier.related_dossiers.should be_empty
    end

    it "should return dossiers linking back" do
      counsil = FactoryGirl.create(:dossier, :title => 'City counsil')
      history = FactoryGirl.create(:dossier, :title => 'City history')
      dossier = FactoryGirl.create(:dossier, :related_to => 'City counsil; City history')

      counsil.related_dossiers.should =~ [dossier]
      history.related_dossiers.should =~ [dossier]
    end
  end

  describe "#back_related_dossiers" do
    it "should return empty list if title is blank" do
      dossier = FactoryGirl.build(:dossier, :title => '')

      dossier.back_related_dossiers.should be_empty
    end

    it "should return dossiers with exact matches" do
      counsil = FactoryGirl.create(:dossier, :title => 'City counsil')
      history = FactoryGirl.create(:dossier, :title => 'City history')
      dossier = FactoryGirl.create(:dossier, :related_to => 'City counsil; City history')
      second = FactoryGirl.create(:dossier, :related_to => 'City counsil')

      history.back_related_dossiers.should =~ [dossier]
      counsil.back_related_dossiers.should =~ [dossier, second]
    end

    it "should not return dossiers with partial matches" do
      counsil = FactoryGirl.create(:dossier, :title => 'City')
      history = FactoryGirl.create(:dossier, :title => 'City history book')
      dossier = FactoryGirl.create(:dossier, :related_to => 'City counsil; City history')

      counsil.back_related_dossiers.should be_empty
      history.back_related_dossiers.should be_empty
    end
  end

  describe "#back_relations" do
    it "should return empty list if title is blank" do
      dossier = FactoryGirl.build(:dossier, :title => '')

      dossier.back_relations.should be_empty
    end

    it "should return dossiers with exact matches" do
      counsil = FactoryGirl.create(:dossier, :title => 'City counsil')
      history = FactoryGirl.create(:dossier, :title => 'City history')
      dossier = FactoryGirl.create(:dossier, :related_to => 'City counsil; City history')
      second = FactoryGirl.create(:dossier, :related_to => 'City counsil')

      history.back_relations.should =~ [dossier.title]
      counsil.back_relations.should =~ [dossier.title, second.title]
    end

    it "should not return dossiers with partial matches" do
      counsil = FactoryGirl.create(:dossier, :title => 'City')
      history = FactoryGirl.create(:dossier, :title => 'City history book')
      dossier = FactoryGirl.create(:dossier, :related_to => 'City counsil; City history')

      counsil.back_relations.should be_empty
      history.back_relations.should be_empty
    end
  end

  describe ".with_dangling_relations" do
    it "should return dossiers with relation with no exact matches" do
      counsil = FactoryGirl.create(:dossier, :title => 'City counsil')
      history = FactoryGirl.create(:dossier, :title => 'City history book')
      dossier = FactoryGirl.create(:dossier, :related_to => 'City counsil; City history')

      Dossier.with_dangling_relations.should == [dossier]
    end

    it "should not return dossiers where all relations have matches" do
      counsil = FactoryGirl.create(:dossier, :title => 'City counsil')
      history = FactoryGirl.create(:dossier, :title => 'City history')
      dossier = FactoryGirl.create(:dossier, :related_to => 'City counsil; City history')

      Dossier.with_dangling_relations.should == []
    end
  end
end
