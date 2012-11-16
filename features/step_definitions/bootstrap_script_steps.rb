Then /^I get a bootstrap script in '(.+)'$/ do |virtual_path|
  File.should exist(
    expand(virtual_path).
    to_flavors_path.
    to_bootstrap_path
  )
end
