Given /^a repository '(.+)' with versions '(.+)'$/ do |basename, versions|
  repository_path = make_repo_path(basename)
  doc_name = basename.split('/').last.sub(/^vim-/, '')
  variable_table["#{basename}_uri"] = make_repo_uri(basename)
  system <<-"END"
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

Given /^a repository '(.+)' from offline cache$/ do |repo_name|
  repository_path = make_repo_path(repo_name)
  system <<-"END"
    {
      git clone 'vendor/#{repo_name}' '#{repository_path}'
    } >/dev/null
  END
end

Given /^I disable network to the original repository of '(.+)'$/ do |basename|
  delete_path make_repo_path(basename)
end

Then /^I get flavor '(.+)' with '(.+)' in '(.+)'$/ do |v_repo_name, version, virtual_path|
  flavor_path = make_flavor_path(expand(virtual_path), expand(v_repo_name))
  basename = expand(v_repo_name).split('/').last.sub(/^vim-/, '')
  File.open("#{flavor_path}/doc/#{basename}.txt", 'r').read().should ==
    "*#{basename}* #{version}\n"
  File.should exist("#{flavor_path}/doc/tags")
end

Then /^I don't have flavor '(.+)' in '(.+)'$/ do |v_repo_name, virtual_path|
  flavor_path = make_flavor_path(expand(virtual_path), expand(v_repo_name))
  Dir.should_not exist(flavor_path)
end
