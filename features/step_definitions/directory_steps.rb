require 'tmpdir'

Given /^I don't have a directory called '(.+)'$/ do |virtual_path|
  Dir.should_not exist(expand(virtual_path))
end

Given /^I delete '(.+)'$/ do |virtual_path|
  delete_path expand(virtual_path)
end

When /^I remove the directory "([^"]*)"$/ do |dir_name|
  in_current_dir do
    # FileUtils#rmdir cannot delete non-empty directories.
    FileUtils.rm_r(dir_name)
  end
end
