class FakeUserEnvironment
  def create_file virtual_path, content
    File.open(expand(virtual_path), 'w') do |f|
      f.write(content)
    end
  end

  def directory_table
    @directory_table ||= Hash.new
  end

  def expand(virtual_path)
    virtual_path.gsub(/\$([a-z]+)/) {
      directory_table[$1]
    }
  end
end

World do
  FakeUserEnvironment.new
end
