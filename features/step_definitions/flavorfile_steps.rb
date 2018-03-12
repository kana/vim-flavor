Given 'a flavorfile with:' do |content|
  steps %Q{
    Given a file named "#{path_for_step(expand_path('.').to_flavorfile_path)}" with:
      """
      #{expand(content)}
      """
  }
end

Given 'an old name flavorfile with:' do |content|
  steps %Q{
    Given a file named "#{path_for_step("#{expand_path('.')}/VimFlavor")}" with:
      """
      #{expand(content)}
      """
  }
end

When 'I edit the flavorfile as:' do |content|
  steps %Q{
    Given a flavorfile with:
      """
      #{content}
      """
  }
end
