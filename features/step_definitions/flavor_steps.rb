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

Given /^I don't have a directory called '(.+)'$/ do |path|
  Dir.should_not exist(path)
end

Given /^I disable network to the original repository of '(.+)'$/ do |basename|
  delete_path make_repo_path(basename)
end

Given /^I delete '(.+)'$/ do |path|
  delete_path expand(path)
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
