Then /^it stores a dependency '(.*)' in '(.*)'$/ do |repo_name, vdir|
  Dir.should exist expand("#{vdir}/#{repo_name.zap}")
end
