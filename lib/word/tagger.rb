module Word
  require 'word_tagger'
  class Tagger < Tagger::WordTagger
    def execute( text )
      super( text.gsub(/[^\w]/,' ') )
    end
  end
end
