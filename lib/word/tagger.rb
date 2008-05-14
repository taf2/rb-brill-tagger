module Word
  require 'word_tagger'
  class Tagger < Tagger::WordTagger
    def initialize( tags_file, options = {} )
      load_tags( RbTagger.tags_from_file( tags_file ) )
      set_words( options[:words] || 2 )
    end

    def execute( text )
      # strip non alpha characters
      super( text.gsub(/[^\w]/,' ') )
    end
  end
end
