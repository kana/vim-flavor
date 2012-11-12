class FakeUserEnvironment
  def directory_table
    @directory_table ||= Hash.new
  end
end

World do
  FakeUserEnvironment.new
end
