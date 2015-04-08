When /^I delete the directory "([^"]*)"$/ do |dir_name|
  in_current_dir do
    # FileUtils#rmdir cannot delete non-empty directories.
    # TODO: Use aruba's "I remove the directory" step.
    #       Currently its implementation cannot delete git repositories.
    FileUtils.rm_r(dir_name)
  end
end
