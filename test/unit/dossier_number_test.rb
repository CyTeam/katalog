require 'test_helper'

class DossierNumberTest < ActiveSupport::TestCase
  def setup
    @new = DossierNumber.new
  end
  
  test "period for numbers with no from date" do
    @new.from = nil
    @new.to   = '1989-12-31'
    @new.number = 9999

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

  test "period simplifies single year" do
    @new.period = "1990 - 1990"
    assert_equal "1990", @new.period
  end
  
  test "period indicates when no from date" do
    @new.from = nil
    @new.to   = '1989-12-31'

    assert_equal "vor 1989", @new.to_s
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
end
