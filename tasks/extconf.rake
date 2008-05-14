namespace :extconf do
  desc "Compiles the Ruby extension"
  task :compile
end

BIN = "*.{bundle,jar,so,obj,pdb,lib,def,exp}"

task :compile => "extconf:compile" do
  Dir["ext/**/*.{bundle,so,dll}"].each do|lib|
    sh "cp #{lib} lib/"
  end
end

task :test => :compile

$hoe.clean_globs |= ["ext/**/#{BIN}", "lib/**/#{BIN}", 'ext/word_tagger/Makefile', 'ext/rule_tagger/Makefile']
$hoe.spec.require_paths = Dir['{lib,ext/*}']
$hoe.spec.extensions = FileList["ext/**/extconf.rb"].to_a
