Then /^a bootstrap script is created in "(.+)"$/ do |v_vimfiles_path|
  p = expand(v_vimfiles_path).to_flavors_path.to_bootstrap_path
  steps %Q{
    Then a file named "#{p}" should exist
  }
end
