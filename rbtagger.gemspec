Gem::Specification.new do |s|
  s.name    = "rbtagger"
  s.authors = ["Todd A. Fisher"]
  s.version = '0.4.7'
  s.date    = '2011-03-30'
  s.description = %q{A Simple Ruby Rule-Based Part of Speech Tagger}
  s.email   = 'todd.fisher@gmail.com'
  s.extra_rdoc_files = ['LICENSE', 'README']
  
  s.files = ["LICENSE", "README", "Rakefile", "lib/brill/brown/LEXICON", "lib/brill/brown/LEXICALRULEFILE", "lib/brill/brown/CONTEXTUALRULEFILE", "lib/brill/brown/Lexicon.rb", "lib/brill/tagger.rb", "lib/rbtagger/version.rb", "lib/rbtagger.rb", "lib/word/tagger.rb", "ext/rule_tagger/darray.c", "ext/rule_tagger/lex.c", "ext/rule_tagger/memory.c", "ext/rule_tagger/rbtagger.c", "ext/rule_tagger/registry.c", "ext/rule_tagger/rules.c", "ext/rule_tagger/tagger.c", "ext/rule_tagger/useful.c", "ext/word_tagger/porter_stemmer.c", "ext/word_tagger/rtagger.cc", "ext/word_tagger/tagger.cc", "ext/word_tagger/test/test.cc", "ext/rule_tagger/bool.h", "ext/rule_tagger/darray.h", "ext/rule_tagger/darrayP.h", "ext/rule_tagger/lex.h", "ext/rule_tagger/memory.h", "ext/rule_tagger/registry.h", "ext/rule_tagger/registryP.h", "ext/rule_tagger/ruby-compat.h", "ext/rule_tagger/rules.h", "ext/rule_tagger/sysdep.h", "ext/rule_tagger/tagger.h", "ext/rule_tagger/useful.h", "ext/word_tagger/porter_stemmer.h", "ext/word_tagger/tagger.h", "ext/rule_tagger/extconf.rb", "ext/word_tagger/extconf.rb", "ext/word_tagger/test.rb"]
  #### Load-time details
  s.require_paths = ['lib','ext']
  s.rubyforge_project = 'curb'
  s.summary = %q{Ruby libcurl bindings}
  s.test_files = []
  
    s.extensions << 'ext/rule_tagger/extconf.rb'
    s.extensions << 'ext/word_tagger/extconf.rb'
  

  #### Documentation and testing.
  s.has_rdoc = true
  s.homepage = 'http://rbtagger.rubyforge.org/'
  s.rdoc_options = ['--main', 'README']

  
    s.platform = Gem::Platform::RUBY
  
end
