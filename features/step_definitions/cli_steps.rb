Then 'it should pass' do
  steps %Q{
    Then it should pass with:
      """
      """
  }
end

Then /^it succeeds$/ do
  @last_error.should be_nil
end

Then /^it fails with messages like$/ do |pattern|
  @last_error.should_not be_nil
  @last_error.message.should match Regexp.new(pattern.strip().gsub(/\s+/, '\s+'))
end

Then 'it outputs progress as follows' do |text|
  # For some reason, Cucumber drops the last newline from every docstring...
  @output.should include expand(text + "\n")
end

Then 'it outputs progress like' do |pattern|
  # For some reason, Cucumber drops the last newline from every docstring...
  @output.should match Regexp.new(expand(pattern + "\n"))
end
