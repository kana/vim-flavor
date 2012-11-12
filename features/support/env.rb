class FakeUserEnvironment
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
