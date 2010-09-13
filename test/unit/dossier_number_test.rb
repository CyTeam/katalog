require 'test_helper'

class DossierNumberTest < ActiveSupport::TestCase
  def setup
    @new = DossierNumber.new
  end
  
  test "period for numbers with no from date" do
    @new.from = nil
    @new.to   = '1989-12-31'
    @new.amount = 9999

    assert_equal "vor 1989: 9999", @new.to_s
  end

  test "period from fixture" do
    assert_equal "1999", dossier_numbers(:city_history_1999).period
    assert_equal "2000 - 2004", dossier_numbers(:city_history_2000_2004).period
  end

  test "*_year and period should work with nil's" do
    assert_equal nil, @new.from_year
    assert_equal nil, @new.to_year
    assert_equal nil, @new.period
    
    @new.to_year = "1990"
    assert_equal nil, @new.from_year
    assert_equal "1990", @new.to_year
    assert_equal "vor 1990", @new.period
  end
    
  test "from_year handles integer and strings" do
    @new.from_year = "1990"
    assert_equal 1990, @new.from.year
    assert_equal "1990", @new.from_year

    @new.from_year = 2000
    assert_equal 2000, @new.from.year
    assert_equal "2000", @new.from_year
  end

  test "to_year handles integer and strings" do
    @new.to_year = "1990"
    assert_equal 1990, @new.to.year
    assert_equal "1990", @new.to_year

    @new.to_year = 2000
    assert_equal 2000, @new.to.year
    assert_equal "2000", @new.to_year
  end

  test "to_year sets nil if assigned nil" do
    @new.to_year = nil
    assert_equal nil, @new.to_year
  end
  
  test "period simplifies single year" do
    @new.period = "1990 - 1990"
    assert_equal "1990", @new.period
  end
  
  test "period handles integer and strings" do
    @new.period = 1990
    assert_equal "1990", @new.from_year
    assert_equal "1990", @new.to_year

    @new.period = "1990 - 2000"
    assert_equal "1990", @new.from_year
    assert_equal "2000", @new.to_year

    @new.period = "1991-2001"
    assert_equal "1991", @new.from_year
    assert_equal "2001", @new.to_year
  end

  test "#to_s returns '- YYYY' if format is :simple " do
    @new.from_year = nil
    @new.to_year = "2009"
    
    assert_equal " - 2009: ", @new.to_s(:simple)
  end
  
  test "#from_s handles single year string" do
    assert_equal [2009, 2009], DossierNumber.from_s("2009")
  end

  test "#from_s handles single year integer" do
    assert_equal [2009, 2009], DossierNumber.from_s(2009)
  end

  test "#from_s handles XXXX - YYYY" do
    assert_equal [2009, 2010], DossierNumber.from_s("2009 - 2010")
  end

  test "#from_s handles - YYYY" do
    assert_equal [ nil, 2010], DossierNumber.from_s(" - 2010")
  end

  test "#from_s handles -YYYY" do
    assert_equal [ nil, 2010], DossierNumber.from_s("-2010")
  end
end
