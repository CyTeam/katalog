ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

require 'thinking_sphinx/test'
ThinkingSphinx::Test.init

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

  # Add more helper methods to be used by all tests here...
  def assert_superset(superset, subset)
    assert superset.to_set.superset?(subset.to_set), "%s is no superset of %s" % [superset.inspect, subset.inspect]
  end

  def assert_same_set(expected, actual)
    assert expected.to_set == actual.to_set, "%s is not the same set as %s" % [expected.inspect, actual.inspect]
  end

  def assert_similar(expected, actual)
    klass = expected.class
    assert_kind_of klass, actual
    
    field_names = klass.content_columns.collect{|c| c.name}.reject{|name| ["created_at", "updated_at"].include?(name)}
    field_names.each {|field_name|
      assert_equal expected[field_name], actual[field_name], "Attribute '%s' of %s" % [field_name, actual.inspect]
    }
  end
end
