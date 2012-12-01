When /^I run `vim-flavor(.*)`(?: again)?(?:,? (but))?$/ do |args, mode|
  begin
    original_home = ENV['HOME']
    ENV['HOME'] = expand('$home')
    Dir.chdir(expand('$tmp')) do
      original_stdout = $stdout
      begin
        $stdout = @output = StringIO.new()
        Vim::Flavor::CLI.start(args.strip().split(/\s+/).map {|a| expand(a)})
      rescue RuntimeError => e
        @last_error = e
      ensure
        $stdout = original_stdout
      end
      if mode == 'but'
        raise RuntimeError, 'Command succeeded unexpectedly' if not @last_error
      else
        raise @last_error if @last_error
      end
    end
  ensure
    ENV['HOME'] = original_home
  end
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
  @output.string.should include expand(text + "\n")
end

Then 'it outputs progress like' do |pattern|
  # For some reason, Cucumber drops the last newline from every docstring...
  @output.string.should match Regexp.new(expand(pattern + "\n"))
end
