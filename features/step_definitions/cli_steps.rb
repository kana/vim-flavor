Then 'it should pass' do
  steps %Q{
    Then it should pass with:
      """
      """
  }
end

Then /^it should (pass|fail) with template:$/ do |pass_fail, template|
  expect(last_command_started).to have_output(an_output_string_including(expand(template)))
  if pass_fail == 'pass'
    expect(last_command_started).to be_successfully_executed
  else
    expect(last_command_started).not_to be_successfully_executed
  end
end

When /^I run `(.*)` \(variables expanded\)$/ do |command|
  steps %Q{
    When I run `#{expand(command)}`
  }
end
