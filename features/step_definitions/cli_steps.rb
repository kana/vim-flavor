When /^I run `vim-flavor(.*)`(?: again)?(?:,? (but))?$/ do |args, mode|
  begin
    original_home = ENV['HOME']
    ENV['HOME'] = expand('$home')
    Dir.chdir(expand('$tmp')) do
      original_stdout = STDOUT.dup()
      File.open('stdout', 'w') do |new_stdout|
        begin
          STDOUT.reopen(new_stdout)
          Vim::Flavor::CLI.start(args.strip().split(/\s+/).map {|a| expand(a)})
        rescue RuntimeError => e
          @last_error = e
        ensure
          STDOUT.reopen(original_stdout)
        end
      end
      @output = File.open('stdout') {|new_stdout| new_stdout.read()}
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
