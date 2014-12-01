require 'test_helper'

class ContainerTypeTest < ActiveSupport::TestCase
  test 'to_s' do
    assert 'Dossier in Hängemappe (DH)', container_types(:DH).to_s
  end
end
