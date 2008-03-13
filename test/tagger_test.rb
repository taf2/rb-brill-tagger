require 'test/unit'
$:.unshift File.join(File.dirname(__FILE__), "..", "..", "lib")
$:.unshift File.join(File.dirname(__FILE__), "..", "..", "ext")

require 'tagger'

module Tagger
  class Rules
    def self.lines( file )
      lines = []
      File.open(file,'r') do|f|
        lines = f.readlines
      end
      lines
    end
    # load LEXICON 
    def self.load_lexicon(tagger,lexicon)
      lines = self.lines(lexicon)
      i = 0
      count = lines.size
      while i < count
        line = lines[i]
        #puts "line: #{line.inspect}:#{i.inspect}"
        parts = line.split(/\s/)
        #puts "word: #{word.inspect}, tags: #{tags.inspect}"
        word = parts.first
        tags = parts[1..-1]
        tagger.add_to_lexicon(word,tags.first)
        #puts "#{word} => #{tags.inspect}"
        tags.each do|tag|
          tagger.add_to_lexicon_tags("#{word} #{tag}")
        end
        i += 1
      end
    end

    # load LEXICALRULEFILE 
    def self.load_lexical_rules(tagger,rules)
      lines = self.lines(rules)
      i = 0
      count = lines.size
=begin
  # original perl
    chomp;
    my @line = split or next;
    $self->_add_lexical_rule($_);

    if ($line[1] eq 'goodright') {
      $self->_add_goodright($line[0]);
    } elsif ($line[2] eq 'fgoodright') {
      $self->_add_goodright($line[1]);
    } elsif ($line[1] eq 'goodleft') {
      $self->_add_goodleft($line[0]);
    } elsif ($line[2] eq 'fgoodleft') {
      $self->_add_goodleft($line[1]);
    }
=end
      while i < count
        line = lines[i].chomp
        cols = line.split(/\s/)
        next unless line.size > 0
        tagger.add_lexical_rule(line)
        if cols[1] == 'goodright'
          tagger.add_goodright(cols[0])
        elsif cols[2] == 'fgoodright'
          tagger.add_goodright(cols[1])
        elsif cols[1] == 'goodleft'
          tagger.add_goodleft(cols[0])
        elsif cols[2] == 'fgoodleft'
          tagger.add_goodleft(cols[1])
        end

        i += 1
      end
    end

    # load CONTEXTUALRULEFILE
    def self.load_contextual_rules(tagger,rules)
      lines = self.lines(rules)
      i = 0
      count = lines.size
      while i < count
        line = lines[i].chomp
        next unless line.size > 0
        tagger.add_contextual_rule(line);
        i += 1
      end
    end

    def self.tag_start(text)
    end

    def self.tokenize(text)
      # Normalize all whitespace
      text.gsub!(/\s+/,' ')
    end

  end
end

class TaggerTest < Test::Unit::TestCase
  def test_simple_tagger
    tagger = Tagger::BrillTagger.new
    puts "load lexicon..."
    Tagger::Rules.load_lexicon(tagger,File.join(File.dirname(__FILE__),"LEXICON"))
    puts "load lexicalrulesfile..."
    Tagger::Rules.load_lexical_rules(tagger,File.join(File.dirname(__FILE__),"LEXICALRULEFILE"))
    puts "load contextualrulesfile..."
    Tagger::Rules.load_contextual_rules(tagger,File.join(File.dirname(__FILE__),"CONTEXTUALRULEFILE"))
  end
end
