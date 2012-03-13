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

  def update_a_test_repo(path)
    system(<<-"END")
      {
        cd #{path.inspect} &&
        echo '*foo* *bar*' >doc/foo.txt &&
        git commit -am 'Update foo again'
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
    before :each do
      @test_repo_path = "#{Vim::Flavor::DOT_PATH}/test/origin"

      @flavor = described_class.new()
      @flavor.repo_uri = @test_repo_path
      @flavor.locked_version = '1.0.0'
    end

    after :each do
      clean_up_stashed_stuffs()
    end

    it 'should fail if the repository is not cloned yet' do
      expect {
        @flavor.fetch()
      }.to raise_error(RuntimeError)
    end

    it 'should fetch recent changes from the repository' do
      create_a_test_repo(@test_repo_path)
      @flavor.clone()
      %x{
        cd #{@flavor.cached_repo_path.inspect}
        git log -n1 --format='%s'
      }.should == "Update foo\n"

      update_a_test_repo(@test_repo_path)

      @flavor.fetch()
      %x{
        cd #{@flavor.cached_repo_path.inspect}
        git log -n1 --format='%s' HEAD
      }.should == "Update foo\n"
      %x{
        cd #{@flavor.cached_repo_path.inspect}
        git log -n1 --format='%s' FETCH_HEAD
      }.should == "Update foo again\n"
    end
  end

  describe '#checkout' do
    before :each do
      @test_repo_path = "#{Vim::Flavor::DOT_PATH}/test/origin"

      @flavor = described_class.new()
      @flavor.repo_uri = @test_repo_path
      @flavor.locked_version = '1.0.0'
    end

    after :each do
      clean_up_stashed_stuffs()
    end

    it 'should checkout the given version' do
      create_a_test_repo(@test_repo_path)
      update_a_test_repo(@test_repo_path)

      @flavor.clone()
      @flavor.checkout()

      head_id = %x{
        cd #{@flavor.cached_repo_path.inspect} &&
        git log -n1 --format='%s' HEAD
      }
      $?.should == 0
      tag_id = %x{
        cd #{@flavor.cached_repo_path.inspect} &&
        git log -n1 --format='%s' #{@flavor.locked_version.inspect}
      }
      $?.should == 0
      head_id.should == tag_id
    end
  end

  describe '#deploy' do
    it 'should deploy files to a given path'
  end

  describe '#undeploy' do
    it 'should remove deployed files'
  end
end
