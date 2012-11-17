#!/usr/bin/env rake
require "bundler/gem_tasks"

task :test => [:spec, :cucumber]

task :spec do
  sh 'bundle exec rspec'
end

task :cucumber do
  sh 'bundle exec cucumber --format=progress'
end
