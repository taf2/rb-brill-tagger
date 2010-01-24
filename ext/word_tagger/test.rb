if $0 == __FILE__
require 'test/unit'
require 'word_tagger'

class NWordTest < Test::Unit::TestCase

  def setup
    if !defined?($tagger)
      $tagger = Tagger::WordTagger.new
      $tagger.load_tags( File.read('../../tags.txt').split("\n") )
      $tagger.set_words( 4 );
    end
  end

  def test_basic
    timer = Time.now
    text = "This is a sa'mple doc[]ument lets see how cancer ngrams 4 works out for this interesting text!"
    tags = $tagger.execute( text )
    assert_equal ['cancer','work'], tags
    puts "Duration: #{Time.now - timer} sec"
  end

  def test_ngram_size3
    timer = Time.now
    text = "This body of text contains something like ventricular septal defect"
    tags = $tagger.execute( text )
    assert_equal ['ventricular septal defect'], tags
    puts "Duration: #{Time.now - timer} sec"
  end
end
end
