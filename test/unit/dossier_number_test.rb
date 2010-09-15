require 'test_helper'

class DossierNumberTest < ActiveSupport::TestCase
  def setup
    @new = Factory :dossier_number
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
    @new.from_year = nil
    @new.to_year = nil
    assert_equal nil, @new.from_year
    assert_equal nil, @new.to_year
    assert_equal nil, @new.period
    
    @new.from_year = nil
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
    assert_equal [Date.new(2009, 1, 1), Date.new(2009, 12, 31), 0], DossierNumber.from_s("2009")
  end

  test "#from_s handles single year integer" do
    assert_equal [Date.new(2009, 1, 1), Date.new(2009, 12, 31), 0], DossierNumber.from_s(2009)
  end

  test "#from_s handles XXXX - YYYY" do
    assert_equal [Date.new(2009, 1, 1), Date.new(2010, 12, 31), 0], DossierNumber.from_s("2009 - 2010")
  end

  test "#from_s handles - YYYY" do
    assert_equal [nil, Date.new(2010, 12, 31), 0], DossierNumber.from_s(" - 2010")
  end

  test "#from_s handles -YYYY" do
    assert_equal [nil, Date.new(2010, 12, 31), 0], DossierNumber.from_s("-2010")
  end

  test "#from_s handles XXXX -" do
    assert_equal [Date.new(2010, 1, 1), nil, 0], DossierNumber.from_s("2010 - ")
  end

  test "#from_s handles XXXX-" do
    assert_equal [Date.new(2010, 1, 1), nil, 0], DossierNumber.from_s("2010-")
  end

  test "#from_s handles XXXX: 77" do
    assert_equal [Date.new(2010, 1, 1), Date.new(2010, 12, 31), 77], DossierNumber.from_s("2010: 77")
  end

  test "#from_s handles XXXX-YYYY: 77" do
    assert_equal [Date.new(2009, 1, 1), Date.new(2010, 12, 31), 77], DossierNumber.from_s("2009-2010: 77")
  end

  test "#from_s returns nil as from and to for : 77" do
    assert_equal [nil, nil, 77], DossierNumber.from_s(": 77")
  end
  
  test ".by_period doesn't return every dossier_number" do
    5.times {Factory :dossier_number_with_amount}
    assert_equal [], DossierNumber.by_period('2009')
  end
  
  test ".by_period does return matching dossier_numbers" do
    4.times {Factory :dossier_number_with_amount, :period => '2010'}
    5.times {Factory :dossier_number_with_amount, :from => Date.new(2009, 1, 1), :to => Date.new(2009, 12, 31)}
    assert_equal 5, DossierNumber.by_period('2009').count
  end
end
