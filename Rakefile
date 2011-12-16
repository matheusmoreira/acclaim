this_dir  = File.expand_path('..', __FILE__)
gem_dir   = File.join this_dir, 'gem'
spec_file = File.join this_dir, 'acclaim.gemspec'

spec = Gem::Specification.load spec_file

task :mkdir do
  FileUtils.mkdir_p gem_dir
end

task :gem => :mkdir do
  gem_file = File.join this_dir, Gem::Builder.new(spec).build
  FileUtils.mv gem_file, gem_dir
end

namespace :gem do

  task :build => :gem

  gem_file = File.join gem_dir, "#{spec.name}-#{spec.version}.gem"

  task :push => :gem do
    sh "gem push #{gem_file}"
  end

  task :install => :gem do
    sh "gem install #{gem_file}"
  end

  task :uninstall do
    sh "gem uninstall #{spec.name}"
  end

  task :clean do
    FileUtils.rm_rf gem_dir
  end

end

task :clean => 'gem:clean'

task :setup => [ 'gem:install', :clean ]

task :default => :setup
