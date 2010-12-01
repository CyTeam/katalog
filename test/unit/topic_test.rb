require 'test_helper'

class TopicTest < ActiveSupport::TestCase
  test "childrens are collected recursivly" do
    assert dossiers(:group_7).children.include?(dossiers(:first_topic))
    assert dossiers(:group_7).children.include?(dossiers(:topic_local))
  end

  test "childrens include dossiers" do
    assert dossiers(:group_7).children.include?(dossiers(:city_counsil))
  end

  test "childrens only include matching signatures" do
    assert !dossiers(:group_7).children.include?(dossiers(:worker_movement_general))
  end

  test "children does not include self" do
    assert !dossiers(:group_empty).children.include?(dossiers(:group_empty))
  end

  test "document_count works" do
    assert 0, dossiers(:group_empty).document_count
  end

  test "document_count returns integer" do
    assert dossiers(:group_7).document_count.is_a?(Integer)
  end
end
