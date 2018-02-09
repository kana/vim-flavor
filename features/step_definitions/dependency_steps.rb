Then /^a dependency "(.*)" is stored in "(.*)"$/ do |repo_name, deps_path|
  cache_path = "#{deps_path}/#{repo_name.zap}"
  steps %Q{
    Then a directory named "#{path_for_step(cache_path)}" should exist
  }
end
