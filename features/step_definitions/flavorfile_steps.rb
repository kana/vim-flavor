Given 'a flavorfile with:' do |content|
  steps %Q{
    Given a file named "#{'.'.to_flavorfile_path}" with:
      """
      #{expand(content)}
      """
  }
end

When 'I edit flavorfile as' do |content|
  steps %Q{
    Given flavorfile
    """
    #{content}
    """
  }
end
