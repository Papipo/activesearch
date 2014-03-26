#!/usr/bin/env rake
# encoding: utf-8

require 'rubygems'
require 'bundler/setup'

require 'rake'
require 'rspec'
require 'rspec/core/rake_task'
require 'rubygems/package_task'

# === Gems install tasks ===
Bundler::GemHelper.install_tasks

RSpec::Core::RakeTask.new('spec') do |spec|
  spec.pattern = 'spec/**/*_spec.rb'
end

task :default => :spec
