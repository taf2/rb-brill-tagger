require 'test/unit'
$:.unshift File.join(File.dirname(__FILE__), "..", "..", "lib")
$:.unshift File.join(File.dirname(__FILE__), "..", "..", "ext")

require 'tagger'

class TaggerTest < Test::Unit::TestCase
  def test_simple_tagger
    puts "hello"
  end
end
