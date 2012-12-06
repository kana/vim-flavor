Given /^an executable file named "(.*)" with:$/ do |file_path, content|
  steps %Q{
    Given a file named "#{file_path}" with:
      """
      #{content}
      """
  }
  File.chmod(0755, File.join([current_dir, file_path]))
end
