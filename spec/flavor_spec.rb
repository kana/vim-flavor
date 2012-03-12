require 'bundler/setup'
require 'fileutils'
require 'vim-flavor'

describe Vim::Flavor::Flavor do
  def create_a_test_repo(path)
    system(<<-"END")
      {
        mkdir -p #{path.inspect}
        cd #{path.inspect}
        git init
        mkdir autoload doc plugin
        touch autoload/foo.vim doc/foo.txt plugin/foo.vim
        git add autoload doc plugin
        git commit -am 'Commit foo'
        echo '*foo*' >doc/foo.txt
        git commit -am 'Update foo'
        git tag -a -m 'Version 1.0.0' 1.0.0
      } >/dev/null
    END
  end

  def clean_up_stashed_stuffs()
    FileUtils.rm_rf([Vim::Flavor::DOT_PATH], :secure => true)
  end

  describe '#clone' do
    before :each do
      @test_repo_path = "#{Vim::Flavor::DOT_PATH}/test/origin"

      @flavor = described_class.new()
      @flavor.repo_uri = @test_repo_path
      @flavor.locked_version = '1.0.0'
    end

    after :each do
      clean_up_stashed_stuffs()
    end

    it 'should clone the repository into a given path' do
      create_a_test_repo(@test_repo_path)

      File.exists?(@flavor.cached_repo_path).should be_false

      @flavor.clone().should be_true

      File.exists?(@flavor.cached_repo_path).should be_true
    end
  end

  describe '#fetch' do
    it 'should fetch recent changes from the repository'
  end

  describe '#checkout' do
    it 'should checkout the given version'
  end

  describe '#deploy' do
    it 'should deploy files to a given path'
  end

  describe '#undeploy' do
    it 'should remove deployed files'
  end
end
