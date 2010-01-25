require 'word_tagger/word_tagger'

module Word
  class Tagger < Tagger::WordTagger
    def initialize( tags, options = {} )
      if tags.is_a?(String) and File.exist?(tags)
        load_tags( RbTagger.tags_from_file( tags ) )
      else
        load_tags( tags )
      end
      set_words( options[:words] || 2 )
    end

    def execute( text )
      # strip non alpha characters
      super( text.gsub(/[^\w]/,' ') )
    end
  end
end
