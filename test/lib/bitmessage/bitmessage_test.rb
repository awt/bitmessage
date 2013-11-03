require 'test/unit'
require_relative '../../test_helper'
class BitmessageTest < Test::Unit::TestCase
  def test_get_messages
    api = Bitmessage::ApiClient.new ENV['BM_URI']
    result = api.add 1, 1
    assert_equal 2, result
  end
end
