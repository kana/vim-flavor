Given 'lockfile' do |content|
  create_file expand('$tmp').to_lockfile_path, expand(content)
end

Given /^I delete lockfile$/ do
  delete_path expand('$tmp').to_lockfile_path
end

Then 'I get lockfile' do |content|
  # For some reason, Cucumber drops the last newline from every docstring...
  File.open(expand('$tmp').to_lockfile_path, 'r').read().should ==
    (content == '' ? '' : expand(content) + "\n")
end
