Given /^a file called '(.*)'$/ do |virtual_path, content|
  create_file expand(virtual_path), expand(content)
end

Given /^an executable called '(.*)'$/ do |virtual_path, content|
  path = expand(virtual_path)
  create_file path, expand(content)
  File.chmod(0755, path)
end
