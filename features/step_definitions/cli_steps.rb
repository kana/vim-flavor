When /^I run `vim-flavor(.*)`(?: again)?(?:,? (but))?$/ do |args, mode|
  begin
    original_home = ENV['HOME']
    ENV['HOME'] = expand('$home')
    Dir.chdir(expand('$tmp')) do
      begin
        Vim::Flavor::CLI.start(args.strip().split(/\s+/).map {|a| expand(a)})
      rescue RuntimeError => e
        @last_error = e
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

Then /^it fails with messages like$/ do |pattern|
  @last_error.should_not be_nil
  @last_error.message.should match Regexp.new(pattern.strip().gsub(/\s+/, '\s+'))
end
