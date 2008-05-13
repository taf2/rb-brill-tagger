module Tagger
  require 'rtagger'
  class SimpleTagger < Tagger::NWordTagger
    def execute( text )
      super( text.gsub(/[^\w]/,' ') )
    end
  end
end
