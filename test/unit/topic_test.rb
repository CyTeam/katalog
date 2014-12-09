require 'test_helper'

class TopicTest < ActiveSupport::TestCase
  test 'topic_type knows group' do
    assert_equal :group, dossiers(:group_7).topic_type
  end

  test 'topic_type knows main' do
    assert_equal :main, dossiers(:first_topic).topic_type
  end

  test 'topic_type knows geo' do
    assert_equal :geo, dossiers(:topic_local).topic_type
  end

  test 'topic_type knows detail' do
    assert_equal :detail, dossiers(:important_zug_topic).topic_type
  end

  test 'children are collected recursivly' do
    assert dossiers(:group_7).children.include?(dossiers(:first_topic))
    assert dossiers(:group_7).children.include?(dossiers(:topic_local))
  end

  test 'children include dossiers' do
    assert dossiers(:group_7).children.include?(dossiers(:city_counsil))
  end

  test 'children only include matching signatures' do
    assert !dossiers(:group_7).children.include?(dossiers(:worker_movement_general))
  end

  test 'children does not include self' do
    assert !dossiers(:group_empty).children.include?(dossiers(:group_empty))
  end

  test 'children no record on new topic' do
    assert_equal 0, Topic.new.children.size
  end

  test 'direct_children no record on new topic' do
    assert_equal 0, Topic.new.direct_children.size
  end

  test 'document_count works' do
    assert_equal 0, dossiers(:group_empty).document_count
  end

  test 'document_count returns integer' do
    assert dossiers(:group_7).document_count.is_a?(Integer)
  end

  test 'move children on signature update if requested' do
    main_topic = dossiers(:first_topic)
    children = main_topic.children.all

    main_topic.update_signature '9'

    assert_equal children, main_topic.children
  end
end
