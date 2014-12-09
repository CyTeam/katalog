require 'test_helper'

class DossiersHelperTest < ActionView::TestCase
  fixtures :sphinx_admins, :dossiers, :containers, :locations

  context 'highlights_words' do
    should 'highlight alternatives' do
      assert_match /'nr'/, highlight_words('nr')
      assert_match /'Nationalrat'/, highlight_words('nr')
    end
  end

  context 'availability' do
    should 'show if available' do
      assert_equal true, waiting_for?(dossiers(:dossier_waiting))
      assert_equal false, waiting_for?(dossiers(:dossier_available))
    end
  end
end
