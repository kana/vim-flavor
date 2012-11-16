require 'fileutils'
require 'tmpdir'

Given /^a temporary directory called '(.+)'$/ do |name|
  path = Dir.mktmpdir
  at_exit do
    FileUtils.remove_entry_secure path
  end
  variable_table[name] = path
end

Given /^a home directory called '(.+)' in '(.+)'$/ do |name, virtual_path|
  actual_path = expand(virtual_path)
  Dir.mkdir actual_path, 0700
  variable_table[name] = actual_path
end

Given /^a repository '(.+)' with versions '(.+)'$/ do |basename, versions|
  repository_path = make_repo_path(basename)
  variable_table["#{basename}_uri"] = make_repo_uri(basename)
  system <<-"END"
    {
      mkdir -p '#{repository_path}' &&
      cd '#{repository_path}' &&
      git init &&
      mkdir doc &&
      for v in #{versions}
      do
        echo "*#{basename}* $v" >'doc/#{basename}.txt'
        git add doc
        git commit -m "Version $v"
        git tag -m "Version $v" "$v"
      done
    } >/dev/null
  END
end

Given 'flavorfile' do |content|
  create_file '$tmp/VimFlavor', expand(content)
end

Given 'lockfile' do |content|
  create_file '$tmp/VimFlavor.lock', expand(content)
end

Given /^I don't have a directory called '(.+)'$/ do |path|
  Dir.should_not exist(path)
end

Given /^I disable network to the original repository of '(.+)'$/ do |basename|
  FileUtils.remove_entry_secure make_repo_path(basename)
end

Given /^I delete '(.+)'$/ do |path|
  FileUtils.remove_entry_secure expand(path)
end

Given /^I delete lockfile$/ do
  FileUtils.remove_entry_secure expand('$tmp').to_lockfile_path
end

When /^I run vim-flavor with '(.+)'(?: again)?$/ do |args|
  begin
    original_home = ENV['HOME']
    ENV['HOME'] = expand('$home')
    Dir.chdir(expand('$tmp')) do
      Vim::Flavor::CLI.start(args.split(/\s+/).map {|a| expand(a)})
    end
  ensure
    ENV['HOME'] = original_home
  end
end

When 'I edit flavorfile as' do |content|
  steps %Q{
    Given flavorfile
    """
    #{content}
    """
  }
end

Then 'I get lockfile' do |content|
  # For some reason, Cucumber drops the last newline from every docstring...
  File.open(expand('$tmp/VimFlavor.lock'), 'r').read().should ==
    expand(content) + "\n"
end

Then /^I get a bootstrap script in '(.+)'$/ do |virtual_path|
  File.should exist(
    expand(virtual_path).
    to_flavors_path.
    to_bootstrap_path
  )
end

Then /^I get flavor '(.+)' with '(.+)' in '(.+)'$/ do |basename, version, virtual_path|
  repo_name = make_repo_uri(basename)
  flavor_path = make_flavor_path(virtual_path, repo_name)
  File.open("#{flavor_path}/doc/#{basename}.txt", 'r').read().should ==
    "*#{basename}* #{version}\n"
end

Then /^I don't have flavor '(.+)' in '(.+)'$/ do |basename, virtual_path|
  repo_name = make_repo_uri(basename)
  flavor_path = make_flavor_path(virtual_path, repo_name)
  Dir.should_not exist(flavor_path)
end
