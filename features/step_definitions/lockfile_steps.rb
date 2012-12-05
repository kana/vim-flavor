Given 'lockfile' do |content|
  create_file expand('$tmp').to_lockfile_path, expand(content)
end

Given /^I delete lockfile$/ do
  delete_path expand('$tmp').to_lockfile_path
end

Then 'a lockfile is created with:' do |content|
  # For some reason, Cucumber drops the last newline from every docstring...
  steps %Q{
    Then the file "#{'.'.to_lockfile_path}" should contain exactly:
      """
      #{content == '' ? '' : expand(content) + "\n"}
      """
  }
end
