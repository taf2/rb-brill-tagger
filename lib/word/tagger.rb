module Word
  require 'word_tagger'
  class Tagger < Tagger::NWordTagger
    def execute( text )
      super( text.gsub(/[^\w]/,' ') )
    end
  end
end
