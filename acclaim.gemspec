#!/usr/bin/env gem build
# encoding: utf-8

current_directory = File.dirname __FILE__
version_file = File.expand_path './acclaim.version', current_directory

Gem::Specification.new 'acclaim' do |gem|

  gem.version = File.read(version_file).chomp
  gem.summary = 'Command-line option parser and command interface.'
  gem.homepage = 'https://github.com/matheusmoreira/acclaim'

  gem.author = 'Matheus Afonso Martins Moreira'
  gem.email = 'matheus.a.m.moreira@gmail.com'

  gem.files = `git ls-files`.split "\n"

  gem.add_runtime_dependency 'jewel'
  gem.add_runtime_dependency 'ribbon'

  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'rookie'

end
