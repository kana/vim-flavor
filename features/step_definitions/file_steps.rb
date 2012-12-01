Given /^a file called '(.*)'$/ do |virtual_path, content|
  create_file expand(virtual_path), expand(content)
end
