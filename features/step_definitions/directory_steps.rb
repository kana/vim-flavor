require 'tmpdir'

Given /^I don't have a directory called '(.+)'$/ do |virtual_path|
  Dir.should_not exist(expand(virtual_path))
end

Given /^I delete '(.+)'$/ do |virtual_path|
  delete_path expand(virtual_path)
end
