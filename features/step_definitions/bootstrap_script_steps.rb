Then /^a bootstrap script (is|is not) created in "(.+)"$/ do |mode, v_vimfiles_path|
  p = expand(v_vimfiles_path).to_flavors_path.to_bootstrap_path
  steps %Q{
    Then a file named "#{p}" #{mode == 'is' ? 'should' : 'should not'} exist
  }
end
