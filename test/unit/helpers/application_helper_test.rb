require 'test_helper'

class ApplicationHelperTest < ActionView::TestCase
  fixtures :dossiers

  context 'topic index' do
    should 'set topic active' do
      @dossier = dossiers(:bfm)
      assert 'active', active?(dossiers(:ejpd))
    end
  end
end
