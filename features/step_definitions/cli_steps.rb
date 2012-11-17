When /^I run `vim-flavor(.*)`(?: again)?$/ do |args|
  raise @last_error if @last_error
  begin
    original_home = ENV['HOME']
    ENV['HOME'] = expand('$home')
    Dir.chdir(expand('$tmp')) do
      begin
        Vim::Flavor::CLI.start(args.strip().split(/\s+/).map {|a| expand(a)})
      rescue RuntimeError => e
        @last_error = e
      end
    end
  ensure
    ENV['HOME'] = original_home
  end
end

Then /^I see error message like '(.+)'$/ do |pattern|
  @last_error.message.should match Regexp.new(pattern)
end
