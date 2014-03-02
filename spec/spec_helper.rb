require 'bundler/setup'
require 'vim-flavor'

module OneLinerExpectSyntax
  def is_expected
    expect(subject)
  end
end

RSpec.configure do |rspec|
  rspec.include OneLinerExpectSyntax
end
