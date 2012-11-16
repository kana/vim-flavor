Given 'flavorfile' do |content|
  create_file '$tmp/VimFlavor', expand(content)
end

When 'I edit flavorfile as' do |content|
  steps %Q{
    Given flavorfile
    """
    #{content}
    """
  }
end
