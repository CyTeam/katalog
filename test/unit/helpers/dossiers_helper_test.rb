require 'test_helper'

class DossiersHelperTest < ActionView::TestCase
  fixtures :sphinx_admins

  context "highlights_words" do
    should "highlight alternatives" do
      assert_match /'nr'/, highlight_words('nr')
      assert_match /'Nationalrat'/, highlight_words('nr')
    end
  end
end
