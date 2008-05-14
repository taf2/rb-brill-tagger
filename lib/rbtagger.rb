$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

module RbTagger
  class << self
    def tags_from_file( file )
      File.read(file).split("\n").map{|t| t.strip}
    end
  end
end

require 'word/tagger'
require 'brill/tagger'
