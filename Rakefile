#!/usr/bin/env rake
require "bundler/gem_tasks"

task :ci => [:dump, :test]

task :dump do
  sh 'vim --version'
end

task :test => [:spec, :cucumber]

task :spec do
  sh 'bundle exec rspec'
end

task :cucumber do
  sh 'bundle exec cucumber --format=progress'
end

task :update_online_documents do
  # Only authorized members can push to relish.
  sh 'bundle exec relish push kana/vim-flavor'
end
