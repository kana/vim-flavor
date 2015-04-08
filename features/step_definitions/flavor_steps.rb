Given /^a (?:(?:GitHub|local) )?repository "([^"]*)"$/ do |basename|
  repository_path = make_repo_path(basename)
  variable_table["#{basename}_uri"] = make_repo_uri(basename)
  sh <<-"END"
    {
      mkdir -p '#{repository_path}' &&
      cd '#{repository_path}' &&
      git init &&
      echo 'README' >README.md &&
      git add README.md &&
      git commit -m 'Write README'
    } >/dev/null
  END
end

Given /^the repository "([^"]*)" has versions "([^"]*)"$/ do |basename, versions|
  add_new_versions_to_repo(basename, versions)
end

Given /^the repository "([^"]*)" has versions "([^"]*)" and a flavorfile:$/ do |basename, versions, flavorfile_content|
  add_new_versions_to_repo(basename, versions, flavorfile_content)
end

Given /^a (?:(?:GitHub|local) )?repository "([^"]*)" with versions "([^"]*)"$/ do |basename, versions|
  steps %Q{
    Given a repository "#{basename}"
    And the repository "#{basename}" has versions "#{versions}"
  }
end

Given /^a (?:(?:GitHub|local) )?repository "([^"]*)" with versions "([^"]*)" and a flavorfile:$/ do |basename, versions, flavorfile_content|
  steps %Q{
    Given a repository "#{basename}"
    And the repository "#{basename}" has versions "#{versions}" and a flavorfile:
      """
      #{flavorfile_content}
      """
  }
end

Given /^"([^"]*)" version "([^"]*)" is released$/ do |basename, version|
  steps %Q{
    Given the repository "#{basename}" has versions "#{version}"
  }
end

Given /^"([^"]*)" has "([^"]*)" branch$/ do |basename, branch|
  repository_path = make_repo_path(basename)
  sh <<-"END"
    {
      cd '#{repository_path}' &&
      git branch '#{branch}'
    } >/dev/null
  END
end

Given /^a repository "([^"]*)" from offline cache$/ do |repo_name|
  repository_path = make_repo_path(repo_name).sub(expand('$tmp/'), '')
  sh <<-"END"
    {
      git clone --quiet --no-checkout 'vendor/#{repo_name}' '#{current_dir}/#{repository_path}'
    } >/dev/null
  END
end

Given /^I disable network to the original repository of "([^"]*)"$/ do |basename|
  steps %Q{
    Given I delete the directory "#{make_repo_path(basename)}"
  }
end

When /^I create a file named "([^"]*)" in "([^"]*)" deployed to "([^"]*)"$/ do |file_name, v_repo_name, v_vimfiles_path|
  flavor_path = make_flavor_path(expand(v_vimfiles_path), expand(v_repo_name))
  steps %Q{
    When I write to "#{flavor_path}/#{file_name}" with:
      """
      """
  }
end

Then /^a flavor "([^"]*)" version "([^"]*)" is deployed to "([^"]*)"$/ do |v_repo_name, version, v_vimfiles_path|
  flavor_path = make_flavor_path(expand(v_vimfiles_path), expand(v_repo_name))
  basename = expand(v_repo_name).split('/').last.sub(/^vim-/, '')
  steps %Q{
    Then the file "#{flavor_path}/doc/#{basename}.txt" should contain:
      """
      *#{basename}* #{version}
      """
    Then a file named "#{flavor_path}/doc/tags" should exist
  }
end

Then /^a flavor "([^"]*)" is not deployed to "([^"]*)"$/ do |v_repo_name, v_vimfiles_path|
  flavor_path = make_flavor_path(expand(v_vimfiles_path), expand(v_repo_name))
  steps %Q{
    Then a directory named "#{flavor_path}" should not exist
  }
end

Then /^"([^"]*)" version "([^"]*)" is (?:(not) )?cached$/ do |v_repo_name, version, p|
  d = make_cached_repo_path(expand(v_repo_name), expand('$home').to_stash_path)
  (system <<-"END").should == (p != 'not')
    {
      cd '#{d}' &&
      git rev-list --quiet '#{version}'
    } >/dev/null 2>&1
  END
end

Then /^a file named "([^"]*)" (should(?: not)?) exist in "([^"]*)" deployed to "([^"]*)"$/ do |file_name, should, v_repo_name, v_vimfiles_path|
  flavor_path = make_flavor_path(expand(v_vimfiles_path), expand(v_repo_name))
  steps %Q{
    Then a file named "#{flavor_path}/#{file_name}" #{should} exist
  }
end
