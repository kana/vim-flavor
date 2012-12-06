Then /^a dependency "(.*)" is stored in "(.*)"$/ do |repo_name, deps_path|
  steps %Q{
    Then a directory named "#{deps_path}/#{repo_name.zap}" should exist
  }
end
