When /^I remove the directory "([^"]*)"$/ do |dir_name|
  in_current_dir do
    # FileUtils#rmdir cannot delete non-empty directories.
    FileUtils.rm_r(dir_name)
  end
end
