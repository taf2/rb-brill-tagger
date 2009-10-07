require 'rule_tagger'

module Brill
  class Tagger
    #
    # will use the brown corpus as the default
    #
    def initialize( lexicon = nil, lexical_rules = nil, contextual_rules = nil)
      @tagger = ::Tagger::BrillTagger.new
      lexicon ||= File.join(File.dirname(__FILE__),"brown","LEXICON")
      lexical_rules ||= File.join(File.dirname(__FILE__),"brown","LEXICALRULEFILE")
      contextual_rules ||= File.join(File.dirname(__FILE__),"brown","CONTEXTUALRULEFILE")

      Brill::Tagger.load_lexicon(@tagger, lexicon )
      Brill::Tagger.load_lexical_rules(@tagger, lexical_rules )
      Brill::Tagger.load_contextual_rules(@tagger, contextual_rules )
    end

    # given a body of text return a list of adjectives
    def adjectives( text )
      tag(text).select{|t| t.last == 'JJ' }
    end

    # given a body of text return a list of nouns
    def nouns( text )
      tag(text).select{|t| t.last.match(/NN/) }
    end

    # returns similar results as tag, but further reduced by only selecting nouns
    def suggest( text, max = 10 )
      tags = tag(text)
      #puts tags.inspect
      ptag = [nil,nil]
      # join NNP's together for names
      reduced_tags = []
      mappings = {} # keep a mapping of the joined words to expand
      tags.each{|tag| 
        if ptag.last == 'NNP' and tag.last == 'NNP' and !ptag.first.match(/\.$/)
          ptag[0] += " " + tag.first
          # before combining these two create a mapping for each word to each word
          words = ptag.first.split(/\s/)
          i = 0
          #puts words.inspect
          until (i + 1) == words.size
            mappings[words[i]] = ptag.first
            mappings[words[i+1]] = ptag.first
            i += 1
          end
          #puts mappings.inspect
        elsif tag.last == 'NNP'
          ptag = tag
        elsif tag.last != 'NNP' and ptag.first != nil
          reduced_tags << ptag
          reduced_tags << tag if tag.last.match( /^\w+$/ ) and tag.first.match(/^\w+$/)
          ptag = [nil,nil]
        elsif tag.last.match( /^\w+$/ ) and tag.first.match(/^\w+$/)
          reduced_tags << tag
        end
      }
      # now expand any NNP that appear
      tags = reduced_tags.map{|tag|
        if tag.last == 'NNP'
          #puts "#{tag.first} => #{mappings[tag.first]}"
          tag[0] = mappings[tag.first] if mappings.key?(tag.first)
        end
        tag
      }
      results = tags.select{|tag| tag.last.match(/NN/) and tag.first.size > 3 }
      if results.size > max
        counts = {}
        tags = []
        results.each {|tag| counts[tag.first] = 0 }
        results.each do |tag|
          tags << tag if counts[tag.first] == 0
          counts[tag.first] += tag.last == 'NNP' ? 3 : (tag.last == 'NNS' ? 2 : 1)
        end
        tags.map!{|tag| [tag.first, tag.last,counts[tag.first]]}
        t = 1
        until tags.size <= max
          tags = tags.sort_by{|tag| tag.last}.select{|tag| tag.last > t }
          t += 1
          if t == 5
            tags = tags.reverse[0..max]
            break
          end
        end
        tags
      else
        results
      end
    end

    # Tag a body of text
    # returns an array like [[token,tag],[token,tag]...[token,tag]] 
    #
    def tag( text )
      # XXX: the list of contractions is much larger then this... find'em
      text = text.gsub(/dont/,"don't").gsub(/Dont/,"Don't")
      text = text.gsub(/youre/,"you're")
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
      text.gsub!(/‘/,'`')
      text.gsub!(/’/,"'")
      text.gsub!(/“/,"``")
      text.gsub!(/”/,"''")

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
