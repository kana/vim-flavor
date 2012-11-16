When /^I run vim-flavor with '(.+)'(?: again)?$/ do |args|
  begin
    original_home = ENV['HOME']
    ENV['HOME'] = expand('$home')
    Dir.chdir(expand('$tmp')) do
      Vim::Flavor::CLI.start(args.split(/\s+/).map {|a| expand(a)})
    end
  ensure
    ENV['HOME'] = original_home
  end
end

When /^I run vim-flavor with '(.+)', though I know it will fail$/ do |args|
  begin
    steps %Q{
      When I run vim-flavor with '#{args}'
    }
  rescue RuntimeError => e
    @last_error = e
  end
end

Then /^I see error message like '(.+)'$/ do |pattern|
  @last_error.message.should match Regexp.new(pattern)
end
