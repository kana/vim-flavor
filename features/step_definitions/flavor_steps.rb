Given /^a (?:(?:GitHub|local) )?repository "(.+)" with versions "(.+)"$/ do |basename, versions|
  repository_path = make_repo_path(basename)
  doc_name = basename.split('/').last.sub(/^vim-/, '')
  variable_table["#{basename}_uri"] = make_repo_uri(basename)
  sh <<-"END"
    {
      mkdir -p '#{repository_path}' &&
      cd '#{repository_path}' &&
      git init &&
      mkdir doc &&
      for v in #{versions}
      do
        echo "*#{doc_name}* $v" >'doc/#{doc_name}.txt'
        git add doc
        git commit -m "Version $v"
        git tag -m "Version $v" "$v"
      done
    } >/dev/null
  END
end

Given /^"(.+)" version "(.+)" is released$/ do |basename, version|
  repository_path = make_repo_path(basename)
  doc_name = basename.split('/').last.sub(/^vim-/, '')
  sh <<-"END"
    {
      cd '#{repository_path}' &&
      for v in #{version}
      do
        echo "*#{doc_name}* $v" >'doc/#{doc_name}.txt'
        git add doc
        git commit -m "Version $v"
        git tag -m "Version $v" "$v"
      done
    } >/dev/null
  END
end

Given /^a repository "(.+)" from offline cache$/ do |repo_name|
  repository_path = make_repo_path(repo_name).sub(expand('$tmp/'), '')
  sh <<-"END"
    {
      git clone 'vendor/#{repo_name}' '#{current_dir}/#{repository_path}'
    } >/dev/null
  END
end

Given /^I disable network to the original repository of "(.+)"$/ do |basename|
  steps %Q{
    Given I remove the directory "#{make_repo_path(basename)}"
  }
end

Then /^a flavor "(.+)" version "(.+)" is deployed to "(.+)"$/ do |v_repo_name, version, v_vimfiles_path|
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

Then /^a flavor "(.+)" is not deployed to "(.+)"$/ do |v_repo_name, v_vimfiles_path|
  flavor_path = make_flavor_path(expand(v_vimfiles_path), expand(v_repo_name))
  steps %Q{
    Then a directory named "#{flavor_path}" should not exist
  }
end

Then /^"(.+)" version "(.+)" is (?:(not) )?cached$/ do |v_repo_name, version, p|
  d = make_cached_repo_path(expand(v_repo_name), expand('$home').to_stash_path)
  (system <<-"END").should == (p != 'not')
    {
      cd '#{d}' &&
      git rev-list --quiet '#{version}'
    } >/dev/null 2>&1
  END
end
