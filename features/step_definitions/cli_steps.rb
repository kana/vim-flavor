Then 'it should pass' do
  steps %Q{
    Then it should pass with:
      """
      """
  }
end

Then /^it should (pass|fail) with template:$/ do |pass_fail, template|
  self.__send__("assert_#{pass_fail}ing_with", expand(template))
end

When /^I run `(.*)` \(variables expanded\)$/ do |command|
  steps %Q{
    When I run `#{expand(command)}`
  }
end
