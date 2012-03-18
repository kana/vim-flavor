require 'bundler/setup'
require 'fileutils'
require 'spec_helper'
require 'vim-flavor'

describe Vim::Flavor::Flavor do
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
    before :each do
      @test_repo_path = "#{Vim::Flavor::DOT_PATH}/test/origin"

      @flavor = described_class.new()
      @flavor.repo_uri = @test_repo_path
      @flavor.locked_version = '1.0.0'

      @vimfiles_path = "#{Vim::Flavor::DOT_PATH}/vimfiles"
      @deploy_path = @flavor.make_deploy_path(@vimfiles_path)
    end

    after :each do
      clean_up_stashed_stuffs()
    end

    it 'should deploy files to a given path' do
      create_a_test_repo(@test_repo_path)
      @flavor.clone()
      @flavor.checkout()

      File.exists?(@deploy_path).should be_false

      @flavor.deploy(@vimfiles_path)

      File.exists?(@deploy_path).should be_true
      File.exists?("#{@deploy_path}/autoload/foo.vim").should be_true
      File.exists?("#{@deploy_path}/doc/foo.txt").should be_true
      File.exists?("#{@deploy_path}/plugin/foo.vim").should be_true
    end

    it 'should :helptags automatically' do
      create_a_test_repo(@test_repo_path)
      @flavor.clone()
      @flavor.checkout()

      File.exists?("#{@deploy_path}/doc/tags").should be_false

      @flavor.deploy(@vimfiles_path)

      File.exists?("#{@deploy_path}/doc/tags").should be_true
    end

    it 'should not care about existing content' do
      create_a_test_repo(@test_repo_path)
      @flavor.clone()
      @flavor.checkout()

      @flavor.deploy(@vimfiles_path)
      system(<<-"END")
        touch '#{@deploy_path}/plugin/oldname.vim'
      END

      File.exists?("#{@deploy_path}/plugin/oldname.vim").should be_true

      @flavor.deploy(@vimfiles_path)

      File.exists?("#{@deploy_path}/plugin/oldname.vim").should be_true
    end
  end

  describe '#undeploy' do
    before :each do
      @test_repo_path = "#{Vim::Flavor::DOT_PATH}/test/origin"

      @flavor = described_class.new()
      @flavor.repo_uri = @test_repo_path
      @flavor.locked_version = '1.0.0'

      @vimfiles_path = "#{Vim::Flavor::DOT_PATH}/vimfiles"
      @deploy_path = @flavor.make_deploy_path(@vimfiles_path)
    end

    after :each do
      clean_up_stashed_stuffs()
    end

    it 'should remove deployed files' do
      create_a_test_repo(@test_repo_path)
      @flavor.clone()
      @flavor.checkout()
      @flavor.deploy(@vimfiles_path)

      File.exists?(@deploy_path).should be_true

      @flavor.undeploy(@vimfiles_path)

      File.exists?(@deploy_path).should be_false
    end
  end

  describe '#list_versions' do
    before :each do
      @test_repo_path = "#{Vim::Flavor::DOT_PATH}/test/origin"

      @flavor = described_class.new()
      @flavor.repo_uri = @test_repo_path
      @flavor.locked_version = '1.0.0'
    end

    after :each do
      clean_up_stashed_stuffs()
    end

    it 'should list tags as versions' do
      create_a_test_repo(@test_repo_path)
      @flavor.clone()
      @flavor.list_versions().should == [
        '1.0.0',
        '1.1.1',
        '1.1.2',
        '1.2.1',
        '1.2.2',
      ].map {|vs| Gem::Version.create(vs)}
    end
  end

  describe '#update_locked_version' do
    before :each do
      @test_repo_path = "#{Vim::Flavor::DOT_PATH}/test/origin"

      @flavor = described_class.new()
      @flavor.repo_uri = @test_repo_path
      @flavor.locked_version = nil
    end

    after :each do
      clean_up_stashed_stuffs()
    end

    it 'should update locked_version according to version_contraint' do
      create_a_test_repo(@test_repo_path)
      @flavor.clone()

      @flavor.version_contraint =
        Vim::Flavor::VersionConstraint.new('>= 0')
      @flavor.update_locked_version()
      @flavor.locked_version.should == Gem::Version.create('1.2.2')

      @flavor.version_contraint =
        Vim::Flavor::VersionConstraint.new('~> 1.1.0')
      @flavor.update_locked_version()
      @flavor.locked_version.should == Gem::Version.create('1.1.2')
    end
  end
end
