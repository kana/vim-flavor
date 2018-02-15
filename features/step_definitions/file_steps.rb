Given /^an executable file named "(.*)" with:$/ do |file_path, content|
  steps %Q{
    Given a file named "#{path_for_step(file_path)}" with:
      """
      #{content}
      """
  }
  File.chmod(0755, File.join([expand_path('.'), file_path]))
end
