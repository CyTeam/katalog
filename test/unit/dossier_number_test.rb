require 'test_helper'

class DossierNumberTest < ActiveSupport::TestCase
  def setup
    @new = DossierNumber.new
  end
  
  test "from_year handles integer and strings" do
    @new.from_year = "1990"
    assert_equal 1990, @new.from.year
    assert_equal 1990, @new.from_year

    @new.from_year = 2000
    assert_equal 2000, @new.from.year
    assert_equal 2000, @new.from_year
  end

  test "to_year handles integer and strings" do
    @new.to_year = "1990"
    assert_equal 1990, @new.to.year
    assert_equal 1990, @new.to_year

    @new.to_year = 2000
    assert_equal 2000, @new.to.year
    assert_equal 2000, @new.to_year
  end

  test "period handles integer and strings" do
    @new.period = 1990
    assert_equal 1990, @new.from_year
    assert_equal 1990, @new.to_year

    @new.period = "1990 - 2000"
    assert_equal 1990, @new.from_year
    assert_equal 2000, @new.to_year

    @new.period = "1991-2001"
    assert_equal 1991, @new.from_year
    assert_equal 2001, @new.to_year
  end
end
