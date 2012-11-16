Given 'lockfile' do |content|
  create_file '$tmp/VimFlavor.lock', expand(content)
end

Given /^I delete lockfile$/ do
  delete_path expand('$tmp').to_lockfile_path
end

Then 'I get lockfile' do |content|
  # For some reason, Cucumber drops the last newline from every docstring...
  File.open(expand('$tmp/VimFlavor.lock'), 'r').read().should ==
    expand(content) + "\n"
end
