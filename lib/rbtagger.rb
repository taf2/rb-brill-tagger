# encoding: utf-8
module RbTagger
  class << self
    def tags_from_file( file )
      File.read(file).split("\n").map{|t| t.strip}
    end
  end
end

require 'word/tagger'
require 'brill/tagger'
