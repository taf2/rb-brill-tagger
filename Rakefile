require 'config/requirements'
require 'config/hoe' # setup Hoe + all gem configuration

Dir['tasks/**/*.rake'].each { |rake| load rake }

# redefine release

desc 'Package and upload the release to rubyforge.'
task :release_current => [:clean, :package] do |t|
  require 'config/hoe'
  version = ENV["VERSION"] or abort "Must supply VERSION=x.y.z"
  name = $hoe.name
  rubyforge_name = $hoe.rubyforge_name
  description = $hoe.description
  pkg = "pkg/#{name}-#{version}"
  abort "Package doesn't exist => #{pkg}" if !File.exist?(pkg)

  rf = RubyForge.new
  puts "Logging in"
  rf.login

  c = rf.userconfig
  c["release_notes"] = description if description
  c["release_changes"] = $hoe.changes if $hoe.changes
  c["preformatted"] = true

  files = [(@need_tar ? "#{pkg}.tgz" : nil),
           (@need_zip ? "#{pkg}.zip" : nil),
           "#{pkg}.gem"].compact

  puts "Releasing #{rubyforge_name} v. #{version}"
  rf.add_release 'ruletagger', 'ruletagger/rbtagger', version, *files
end
