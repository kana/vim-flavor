require 'tmpdir'

Given /^a temporary directory called '(.+)'$/ do |name|
  path = Dir.mktmpdir
  at_exit do
    delete_path path
  end
  variable_table[name] = path
end

Given /^a home directory called '(.+)' in '(.+)'$/ do |name, virtual_path|
  actual_path = expand(virtual_path)
  Dir.mkdir actual_path, 0700
  variable_table[name] = actual_path
end

Given /^I don't have a directory called '(.+)'$/ do |path|
  Dir.should_not exist(expand(path))
end

Given /^I delete '(.+)'$/ do |path|
  delete_path expand(path)
end
