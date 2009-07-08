require File.dirname(__FILE__) + '/test_helper'

class TestWordTagger < Test::Unit::TestCase
  
  def setup
    if !defined?($wtagger)
      $wtagger = Word::Tagger.new( File.join(File.dirname(__FILE__),'fixtures','tags.txt'), :words => 4 )
    end
  end

  def test_basic
    timer = Time.now
    text = "This is a sa'mple doc[]ument lets see how cancer ngrams 4 works out for this interesting text!"
    tags = $wtagger.execute( text )
    assert_equal ['cancer','work'], tags
    puts "Duration: #{Time.now - timer} sec"
  end

  def test_sample_bug
    tags = ["foo", "bar", "baz", "squishy", "yummy"]
    txt = 'This is some sample text. Foo walked into a bar. The bartender said "What can I get you?" Foo said he wanted something yummy - like a baz.'
    tagger = Word::Tagger.new tags, :words => 4
    result_tags = tagger.execute( txt )
    assert_equal ["bar", "baz", "foo", "yummy"], result_tags
  end

  def test_ngram_size3
    timer = Time.now
    text = "This body of text contains something like ventricular septal defect"
    tags = $wtagger.execute( text )
    assert_equal ['ventricular septal defect'], tags
    puts "Duration: #{Time.now - timer} sec"
  end

  def test_cat_and_the_hat
    tagger = Word::Tagger.new( ['Cat','hat'], :words => 4 )
    tags = tagger.execute( 'the cAt and the hat' )
    assert_equal( ["Cat", "hat"], tags )
  end

  def test_freq_counts
    tagger = Word::Tagger.new( ['Cat','hat'], :words => 4 )
    tags = tagger.freq( 'the cAt and the hat the cAt and the hat the cAt and the hat the cAt and the hat' )
    assert_equal( {"Cat"=>4, "hat"=>4}, tags )
  end

end
