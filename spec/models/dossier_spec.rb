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

  describe "#extract_tags" do
    it "should split at most special characters" do
      tags = ["War. Peace", "Ying and Yang", "Mandela, Nelson", "All (really) all; to say: every-thing."]
      Dossier.extract_tags(tags).should == ["War", "Peace", "Ying", "and", "Yang", "Mandela", "Nelson", "All", "really", "all", "to", "say", "every", "thing"]
    end

    it "should drop numbers" do
      tags = ["1. World War (1914-1918)", "1'000'000 pieces", "3.5 pounds"]
      Dossier.extract_tags(tags).should == ["World", "War", "pieces", "pounds"]
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

      dossier.relations.should == []
    end

    it "should return empty array when blank" do
      dossier = FactoryGirl.build(:dossier, :related_to => '  ')

      dossier.relations.should == []
    end

    it "should split at ;" do
      dossier = FactoryGirl.build(:dossier, :related_to => 'City counsil; City history')

      dossier.relations.should == ['City counsil', 'City history']
    end

    it "should strip whitespaces" do
      dossier = FactoryGirl.build(:dossier, :related_to => ' City counsil; City history ')

      dossier.relations.should == ['City counsil', 'City history']
    end

    it "should drop empty relations" do
      dossier = FactoryGirl.build(:dossier, :related_to => '; City counsil;; City history ')

      dossier.relations.should == ['City counsil', 'City history']
    end
  end
end
