require 'rake/clean'
require 'rake/testtask'
require 'rake/rdoctask'
$:.unshift File.expand_path(File.dirname(__FILE__))
$:.unshift File.expand_path(File.dirname(__FILE__), 'lib')
$:.unshift File.expand_path(File.dirname(__FILE__), 'ext')

CLEAN.include '**/*.o'
CLEAN.include "**/*.#{Config::MAKEFILE_CONFIG['DLEXT']}"
CLOBBER.include 'doc'
CLOBBER.include '**/*.log'
CLOBBER.include '**/Makefile'
CLOBBER.include '**/extconf.h'

# Make tasks -----------------------------------------------------
make_program = (/mswin/ =~ RUBY_PLATFORM) ? 'nmake' : 'make'
MAKECMD = ENV['MAKE_CMD'] || make_program
MAKEOPTS = ENV['MAKE_OPTS'] || ''

RULE_SO = "ext/rule_tagger/rule_tagger.#{Config::MAKEFILE_CONFIG['DLEXT']}"
WORD_SO = "ext/word_tagger/word_tagger.#{Config::MAKEFILE_CONFIG['DLEXT']}"

def make(mod,target = '')
  Dir.chdir("ext/#{mod}_tagger") do 
    pid = system("#{MAKECMD} #{MAKEOPTS} #{target}")
    $?.exitstatus
  end    
end

file 'ext/word_tagger/Makefile' => 'ext/word_tagger/extconf.rb' do
  Dir.chdir('ext/word_tagger') { ruby "extconf.rb #{ENV['EXTCONF_OPTS']}" }
end

file 'ext/rule_tagger/Makefile' => 'ext/rule_tagger/extconf.rb' do
  Dir.chdir('ext/rule_tagger') { ruby "extconf.rb #{ENV['EXTCONF_OPTS']}" }
end

# Let make handle dependencies between c/o/so - we'll just run it. 
file RULE_SO => (['ext/rule_tagger/Makefile','ext/rule_tagger/extconf.rb'] + Dir['ext/rule_tagger/*.cc'] + Dir['ext/rule_tagger/*.h']) do
  m = make('rule')
  fail "Make failed (status #{m})" unless m == 0
end

file WORD_SO => (['ext/word_tagger/Makefile','ext/rule_tagger/extconf.rb'] + Dir['ext/word_tagger/*.cc'] + Dir['ext/word_tagger/*.h']) do
  m = make('word')
  fail "Make failed (status #{m})" unless m == 0
end

desc "Compile the shared object"
task :compile => [RULE_SO, WORD_SO]

Rake::TestTask.new(:inttest) do |t|
  t.test_files = FileList['test/test_*.rb']
  t.verbose = false
end

desc "Test taggers"
task :test => [:compile, :inttest]

task :default => :test

desc 'Generate gem specification'
task :gemspec do
  require 'erb'
  tspec = ERB.new(File.read(File.join(File.dirname(__FILE__),'lib','rbtagger.gemspec.erb')))
  File.open(File.join(File.dirname(__FILE__),'rbtagger.gemspec'),'wb') do|f|
    f << tspec.result
  end
end
require 'lib/rbtagger/version'
CURRENT_VERSION = RbTagger::VERSION::STRING
desc 'Build gem'
task :package => :gemspec do
  require 'rubygems/specification'
  spec_source = File.read File.join(File.dirname(__FILE__),'rbtagger.gemspec')
  spec = nil
  # see: http://gist.github.com/16215
  Thread.new { spec = eval("$SAFE = 3\n#{spec_source}") }.join
  spec.validate
  Gem::Builder.new(spec).build
end
