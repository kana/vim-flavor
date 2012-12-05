Given 'a lockfile with:' do |content|
  steps %Q{
    Given a file named "#{'.'.to_lockfile_path}" with:
      """
      #{expand(content)}
      """
  }
end

Given /^I delete lockfile$/ do
  delete_path expand('$tmp').to_lockfile_path
end

Then /^(?:a|the) lockfile is (?:created|updated) with:$/ do |content|
  # For some reason, Cucumber drops the last newline from every docstring...
  steps %Q{
    Then the file "#{'.'.to_lockfile_path}" should contain exactly:
      """
      #{content == '' ? '' : expand(content) + "\n"}
      """
  }
end
