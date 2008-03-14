# much of this file orginated as part of mongrel
require 'rake'
require 'rake/testtask'
require 'rake/clean'
require 'rake/gempackagetask'
require 'rake/rdoctask'
require 'tools/rakehelp'
require 'fileutils'
include FileUtils

setup_tests

setup_clean ["ext/rule_tagger/*.{bundle,so,obj,pdb,lib,def,exp}", "ext/rule_tagger/Makefile", "pkg", "lib/*.bundle", "*.gem", "doc/site/output", ".config"]

setup_rdoc ['README', 'LICENSE', 'COPYING', 'lib/**/*.rb', 'doc/**/*.rdoc', 'ext/**/*.{h,c,rl}']

desc "Does a full compile, test run"
task :default => [:compile, :test]

desc "Compiles all extensions"
task :compile => [:rule_tagger] do
  if Dir.glob(File.join("lib","rule_tagger.*")).length == 0
    STDERR.puts "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    STDERR.puts "Gem actually failed to build.  Your system is"
    STDERR.puts "NOT configured properly to build Tagger."
    STDERR.puts "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    exit(1)
  end
end

setup_extension("rule_tagger", "rule_tagger")

task :package => [:clean,:compile,:test,:rerdoc]

name="rule_tagger"
version="0.0.1"

setup_gem(name, version) do |spec|
  spec.summary = "A Simple Ruby Rule-Based Part of Speech Tagger"
  spec.description = spec.summary
  spec.test_files = Dir.glob('test/test_*.rb')
  spec.author="Todd A. Fisher"
  spec.files += %w(COPYING LICENSE README Rakefile setup.rb)

  spec.required_ruby_version = '>= 1.8.5'
end

task :install do
  sh %{rake package}
  sh %{gem install pkg/#{name}-#{version}}
end

task :uninstall => [:clean] do
  sh %{gem uninstall #{name}}
end
