require 'rule_tagger'

module Brill
  class Tagger
    def initialize( lexicon, lexical_rules, contextual_rules )
      @tagger = ::Tagger::BrillTagger.new
      Brill::Tagger.load_lexicon(@tagger,lexicon)
      Brill::Tagger.load_lexical_rules(@tagger,lexical_rules)
      Brill::Tagger.load_contextual_rules(@tagger,contextual_rules)
    end

    # Tag a body of text
    # returns an array like [[token,tag],[token,tag]...[token,tag]] 
    #
    def tag( text )
      tokens = Brill::Tagger.tokenize( text )
      tags = Brill::Tagger.tag_start( tokens )

      @tagger.apply_lexical_rules( tokens, tags, [], 0 )
      @tagger.default_tag_finish( tokens, tags )
 
      # Brill uses these fake "STAART" tags to delimit the start & end of sentence.
      tokens << "STAART" 
      tokens << "STAART" 
      tokens.unshift "STAART"
      tokens.unshift "STAART"
      tags << "STAART" 
      tags << "STAART" 
      tags.unshift "STAART"
      tags.unshift "STAART"

      @tagger.apply_contextual_rules( tokens, tags, 1 )

      tags.shift
      tags.shift
      tokens.shift
      tokens.shift
      tags.pop
      tags.pop
      tokens.pop
      tokens.pop

      pairs = []
      tokens.each_with_index do|t,i|
        pairs << [t,tags[i]]
      end
      pairs
    end
  private
    def self.lines( file )
      lines = []
      File.open(file,'r') do|f|
        lines = f.readlines
      end
      lines
    end
    # load LEXICON 
    def self.load_lexicon(tagger,lexicon)
      lines = Brill::Tagger.lines(lexicon)
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

    def self.tag_start(tokens)
      tokens.map{|token| token.match(/^[A-Z]/) ? 'NNP' : 'NN' }
    end

    # this tokenize code is a port from perl
    def self.tokenize(text)
      # Normalize all whitespace
      text = text.gsub(/\s+/,' ')

      # translate some common extended ascii characters to quotes
      text.gsub!(/#{145.chr}/,'`')
      text.gsub!(/#{146.chr}/,"'")
      text.gsub!(/#{147.chr}/,"``")
      text.gsub!(/#{148.chr}/,"''")

      # Attempt to get correct directional quotes
      # s{\"\b} { `` }g;
      text.gsub!(/\"\b/,' `` ')
      # s{\b\"} { '' }g;
      text.gsub!(/\b\"/," '' ")
      #s{\"(?=\s)} { '' }g;
      text.gsub!(/\"(?=\s)/," '' ")
      #s{\"} { `` }g;
      text.gsub!(/\"(?=\s)/," `` ")

      # Isolate ellipses
      # s{\.\.\.}   { ... }g;
      text.gsub!(/\.\.\./,' ... ')


      # Isolate any embedded punctuation chars
      #   s{([,;:\@\#\$\%&])} { $1 }g;
      text.gsub!(/([,;:\@\#\$\%&])/, ' \1 ')
  
      # Assume sentence tokenization has been done first, so split FINAL
      # periods only.
      # s/ ([^.]) \.  ([\]\)\}\>\"\']*) [ \t]* $ /$1 .$2 /gx;
      text.gsub!(/ ([^.]) \.  ([\]\)\}\>\"\']*) [ \t]* $ /x, '\1 .\2 ')

      # however, we may as well split ALL question marks and exclamation points,
      # since they shouldn't have the abbrev.-marker ambiguity problem
      #s{([?!])} { $1 }g;
      text.gsub!(/([?!])/, ' \1 ')

      # parentheses, brackets, etc.
      #s{([\]\[\(\)\{\}\<\>])} { $1 }g;
      text.gsub!(/([\]\[\(\)\{\}\<\>])/,' \1 ')

      #s/(-{2,})/ $1 /g;
      text.gsub!(/(-{2,})/,' \1 ')

      # Add a space to the beginning and end of each line, to reduce
      # necessary number of regexps below.
      #s/$/ /;
      text.gsub!(/$/," ")
      #s/^/ /;
      text.gsub!(/^/," ")

      # possessive or close-single-quote
      #s/\([^\']\)\' /$1 \' /g;
      text.gsub!(/\([^\']\)\' /,%q(\1 ' ))

      # as in it's, I'm, we'd
      #s/\'([smd]) / \'$1 /ig;
      text.gsub!(/\'([smd]) /i,%q( '\1 ))

      #s/\'(ll|re|ve) / \'$1 /ig;
      text.gsub!(/\'(ll|re|ve) /i,%q( '\1 ))
      #s/n\'t / n\'t /ig;
      text.gsub!(/n\'t /i,"  n't ")

      #s/ (can)(not) / $1 $2 /ig;
      text.gsub!(/ (can)(not) /i,' \1 \2 ')
      #s/ (d\')(ye) / $1 $2 /ig;
      text.gsub!(/ (d\')(ye) /i,' \1 \2 ')
      #s/ (gim)(me) / $1 $2 /ig;
      text.gsub!(/ (gim)(me) /i,' \1 \2 ')
      #s/ (gon)(na) / $1 $2 /ig;
      text.gsub!(/ (gon)(na) /i,' \1 \2 ')
      #s/ (got)(ta) / $1 $2 /ig;
      text.gsub!(/ (got)(ta) /i,' \1 \2 ')
      #s/ (lem)(me) / $1 $2 /ig;
      text.gsub!(/ (lem)(me) /i,' \1 \2 ')
      #s/ (more)(\'n) / $1 $2 /ig;
      text.gsub!(/ (more)(\'n) /i,' \1 \2 ')
      #s/ (\'t)(is|was) / $1 $2 /ig;
      text.gsub!(/ (\'t)(is|was) /i,' \1 \2 ')
      #s/ (wan)(na) / $1 $2 /ig;
      text.gsub!(/ (wan)(na) /i,' \1 \2 ')
 
      text.split(/\s/)
    end

  end
end
