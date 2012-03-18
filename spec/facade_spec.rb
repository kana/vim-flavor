require 'bundler/setup'
require 'fileutils'
require 'spec_helper'
require 'vim-flavor'

describe Vim::Flavor::Facade do
  describe '#initialize' do
    it 'should have proper values by default' do
      facade = described_class.new()
      facade.flavorfile.should == nil
      facade.flavorfile_path.should == "#{Dir.getwd()}/VimFlavor"
      facade.lockfile.should == nil
      facade.lockfile_path.should == "#{Dir.getwd()}/VimFlavor.lock"
    end
  end

  describe '#load' do
    before :each do
      @tmp_path = "#{Vim::Flavor::DOT_PATH}/tmp"
      @facade = described_class.new()
      @facade.flavorfile_path = "#{@tmp_path}/VimFlavor"
      @facade.lockfile_path = "#{@tmp_path}/VimFlavor.lock"

      @flavor1 = Vim::Flavor::Flavor.new()
      @flavor1.groups = [:default]
      @flavor1.repo_name = 'kana/vim-smartinput'
      @flavor1.repo_uri = 'git://github.com/kana/vim-smartinput.git'
      @flavor1.version_contraint =
        Vim::Flavor::VersionConstraint.new('>= 0')
      @flavor2 = Vim::Flavor::Flavor.new()
      @flavor2.groups = [:default]
      @flavor2.repo_name = 'kana/vim-smarttill'
      @flavor2.repo_uri = 'git://github.com/kana/vim-smarttill.git'
      @flavor2.version_contraint =
        Vim::Flavor::VersionConstraint.new('>= 0')

      FileUtils.mkdir_p(@tmp_path)
      File.open(@facade.flavorfile_path, 'w') do |f|
        f.write(<<-'END')
          flavor 'kana/vim-smartinput'
          flavor 'kana/vim-smarttill'
        END
      end
      File.open(@facade.lockfile_path, 'w') do |f|
        f.write(<<-'END')
          :flavors:
            - foo
            - bar
        END
      end
    end

    after :each do
      FileUtils.rm_rf([Vim::Flavor::DOT_PATH], :secure => true)
    end

    it 'should load both files' do
      @facade.load()

      @facade.flavorfile_path.should == "#{@tmp_path}/VimFlavor"
      @facade.lockfile_path.should == "#{@tmp_path}/VimFlavor.lock"
      @facade.flavorfile.flavors.keys.length == 2
      @facade.flavorfile.flavors[@flavor1.repo_uri].should == @flavor1
      @facade.flavorfile.flavors[@flavor2.repo_uri].should == @flavor2
      @facade.lockfile.flavors.should == ['foo', 'bar']
    end

    it 'should load a lockfile if it exists' do
      @facade.load()

      @facade.lockfile.flavors.should == ['foo', 'bar']

      @facade.lockfile_path = "#{@tmp_path}/VimFlavor.lock.xxx"
      @facade.load()

      @facade.lockfile.flavors.should == {}
    end
  end

  describe '#make_new_flavors' do
    before :each do
      @facade = described_class.new()

      @f0 = Vim::Flavor::Flavor.new()
      @f0.repo_name = 'kana/vim-textobj-entire'
      @f0.repo_uri = 'git://github.com/kana/vim-textobj-entire.git'
      @f0.version_contraint = Vim::Flavor::VersionConstraint.new('>= 0')
      @f0.locked_version = Gem::Version.create('0')

      @f1 = @f0.dup()
      @f1.locked_version = Gem::Version.create('2')

      @f1d = @f1.dup()
      @f1d.version_contraint = Vim::Flavor::VersionConstraint.new('>= 1')
    end

    it 'should keep current locked_version for newly added flavors' do
      @facade.make_new_flavors(
        {
          @f0.repo_uri => @f0,
        },
        {
        },
        :install
      ).should == {
        @f0.repo_uri => @f0,
      }
    end

    it 'should keep current locked_version for flavors with new constraint' do
      @facade.make_new_flavors(
        {
          @f1d.repo_uri => @f1d,
        },
        {
          @f0.repo_uri => @f0,
        },
        :install
      ).should == {
        @f1d.repo_uri => @f1d,
      }
    end

    it 'should keep current locked_version for :update mode' do
      @facade.make_new_flavors(
        {
          @f1.repo_uri => @f1,
        },
        {
          @f0.repo_uri => @f0,
        },
        :update
      ).should == {
        @f1.repo_uri => @f1,
      }
    end

    it 'should keep locked flavors otherwise' do
      @facade.make_new_flavors(
        {
          @f1.repo_uri => @f1,
        },
        {
          @f0.repo_uri => @f0,
        },
        :install
      ).should == {
        @f0.repo_uri => @f0,
      }
    end

    it 'should always use current groups even if locked version is updated' do
      f0 = @f0.dup()
      f0.groups = [:default]
      f1 = @f1.dup()
      f1.groups = [:default, :development]
      f1d = f1.dup()
      f1d.locked_version = f0.locked_version

      @facade.make_new_flavors(
        {
          f1.repo_uri => f1,
        },
        {
          f0.repo_uri => f0,
        },
        :install
      ).should == {
        f1d.repo_uri => f1d,
      }
    end
  end

  describe '#deploy_flavors' do
    before :each do
      @facade = described_class.new()

      @test_repo_path = "#{Vim::Flavor::DOT_PATH}/test/origin"

      @flavor = Vim::Flavor::Flavor.new()
      @flavor.repo_uri = @test_repo_path
      @flavor.locked_version = '1.0.0'

      @flavors = [@flavor]

      @vimfiles_path = "#{Vim::Flavor::DOT_PATH}/vimfiles"
    end

    after :each do
      FileUtils.rm_rf([Vim::Flavor::DOT_PATH], :secure => true)
    end

    it 'should replace a given path with given flavors' do
      create_a_test_repo(@test_repo_path)
      @flavors.each do |f|
        f.clone()
      end

      File.exists?(@vimfiles_path).should be_false
      @flavors.each do |f|
        File.exists?(f.make_deploy_path(@vimfiles_path)).should be_false
      end

      @facade.deploy_flavors(@flavors, @vimfiles_path)

      File.exists?(@vimfiles_path).should be_true
      @flavors.each do |f|
        File.exists?(f.make_deploy_path(@vimfiles_path)).should be_true
      end

      system(<<-"END")
        touch '#{@vimfiles_path}/foo'
        touch '#{@vimfiles_path}/flavors/foo'
      END

      File.exists?("#{@vimfiles_path}/foo").should be_true
      File.exists?("#{@vimfiles_path}/flavors/foo").should be_true

      @facade.deploy_flavors(@flavors, @vimfiles_path)

      File.exists?("#{@vimfiles_path}/foo").should be_true
      File.exists?("#{@vimfiles_path}/flavors/foo").should be_false
    end
  end

  describe '#save_lockfile' do
    before :each do
      @tmp_path = "#{Vim::Flavor::DOT_PATH}/tmp"
      @facade = described_class.new()
      @facade.flavorfile_path = "#{@tmp_path}/VimFlavor"
      @facade.lockfile_path = "#{@tmp_path}/VimFlavor.lock"

      FileUtils.mkdir_p(@tmp_path)
      File.open(@facade.flavorfile_path, 'w') do |f|
        f.write(<<-'END')
        END
      end
    end

    after :each do
      clean_up_stashed_stuffs()
    end

    it 'should save locked flavors' do
      @facade.load()

      @facade.lockfile.flavors.should == {}

      flavor1 = Vim::Flavor::Flavor.new()
      flavor1.groups = [:default]
      flavor1.repo_name = 'kana/vim-smartinput'
      flavor1.repo_uri = 'git://github.com/kana/vim-smartinput.git'
      flavor1.version_contraint =
        Vim::Flavor::VersionConstraint.new('>= 0')
      @facade.lockfile.instance_eval do
        @flavors = {
          flavor1.repo_uri => flavor1,
        }
      end
      @facade.save_lockfile()
      @facade.lockfile.instance_eval do
        @flavors = nil
      end

      @facade.lockfile.flavors.should == nil

      @facade.load()

      @facade.lockfile.flavors.should == {
        flavor1.repo_uri => flavor1,
      }
    end
  end

  describe '#complete_locked_flavors' do
    before :each do
      @test_repo_path = "#{Vim::Flavor::DOT_PATH}/test/origin"
      @tmp_path = "#{Vim::Flavor::DOT_PATH}/tmp"
      @facade = described_class.new()
      @facade.flavorfile_path = "#{@tmp_path}/VimFlavor"
      @facade.lockfile_path = "#{@tmp_path}/VimFlavor.lock"

      create_a_test_repo(@test_repo_path)
      FileUtils.mkdir_p(@tmp_path)
      File.open(@facade.flavorfile_path, 'w') do |f|
        f.write(<<-"END")
          flavor 'file://#{@test_repo_path}', '~> 1.1.1'
        END
      end
    end

    after :each do
      clean_up_stashed_stuffs()
    end

    it 'should complete flavors if they are not locked' do
      @facade.load()

      cf1 = @facade.flavorfile.flavors.values[0]
      cf1.locked_version.should be_nil
      File.exists?(cf1.cached_repo_path).should be_false
      @facade.lockfile.flavors.should == {}

      @facade.complete_locked_flavors(:upgrade_if_necessary)

      lf1 = @facade.lockfile.flavors.values[0]
      lf1.locked_version.should == Gem::Version.create('1.1.2')
      File.exists?(lf1.cached_repo_path).should be_true
      @facade.lockfile.flavors.should == {
        lf1.repo_uri => lf1,
      }

      @facade.complete_locked_flavors(:upgrade_if_necessary)

      lf1d = @facade.lockfile.flavors.values[0]
      lf1d.locked_version.should == Gem::Version.create('1.1.2')
      File.exists?(lf1d.cached_repo_path).should be_true
      @facade.lockfile.flavors.should == {
        lf1d.repo_uri => lf1d,
      }
    end

    it 'should complete flavors if their constraint are changed' do
      @facade.load()

      cf1 = @facade.flavorfile.flavors.values[0]
      cf1.locked_version.should be_nil
      File.exists?(cf1.cached_repo_path).should be_false
      @facade.lockfile.flavors.should == {}

      @facade.complete_locked_flavors(:upgrade_if_necessary)

      lf1 = @facade.lockfile.flavors.values[0]
      lf1.locked_version.should == Gem::Version.create('1.1.2')
      File.exists?(lf1.cached_repo_path).should be_true
      @facade.lockfile.flavors.should == {
        lf1.repo_uri => lf1,
      }

      cf1.version_contraint = Vim::Flavor::VersionConstraint.new('~> 1.1.2')
      update_a_test_repo(@test_repo_path)
      @facade.complete_locked_flavors(:upgrade_if_necessary)

      lf1d = @facade.lockfile.flavors.values[0]
      lf1d.locked_version.should == Gem::Version.create('1.1.9')
      File.exists?(lf1d.cached_repo_path).should be_true
      @facade.lockfile.flavors.should == {
        lf1d.repo_uri => lf1d,
      }
    end

    it 'should upgrade flavors even if their constraint are not changed' do
      @facade.load()

      cf1 = @facade.flavorfile.flavors.values[0]
      cf1.locked_version.should be_nil
      File.exists?(cf1.cached_repo_path).should be_false
      @facade.lockfile.flavors.should == {}

      @facade.complete_locked_flavors(:upgrade_all)

      lf1 = @facade.lockfile.flavors.values[0]
      lf1.locked_version.should == Gem::Version.create('1.1.2')
      File.exists?(lf1.cached_repo_path).should be_true
      @facade.lockfile.flavors.should == {
        lf1.repo_uri => lf1,
      }

      update_a_test_repo(@test_repo_path)
      @facade.complete_locked_flavors(:upgrade_all)

      lf1d = @facade.lockfile.flavors.values[0]
      lf1d.locked_version.should == Gem::Version.create('1.1.9')
      File.exists?(lf1d.cached_repo_path).should be_true
      @facade.lockfile.flavors.should == {
        lf1d.repo_uri => lf1d,
      }
    end
  end

  describe '#get_default_vimfiles_path' do
    it 'should return an appropriate value for *nix' do
      # FIXME: Add proper tests depending on the current environment.
      @facade = described_class.new()
      @facade.get_default_vimfiles_path().should == "#{ENV['HOME']}/.vim"
    end
  end

  describe '#install' do
    before :each do
      @test_repo_path = "#{Vim::Flavor::DOT_PATH}/test/origin"
      @tmp_path = "#{Vim::Flavor::DOT_PATH}/tmp"
      @vimfiles_path = "#{Vim::Flavor::DOT_PATH}/vimfiles"
      @facade = described_class.new()
      @facade.flavorfile_path = "#{@tmp_path}/VimFlavor"
      @facade.lockfile_path = "#{@tmp_path}/VimFlavor.lock"

      create_a_test_repo(@test_repo_path)
      FileUtils.mkdir_p(@tmp_path)
      File.open(@facade.flavorfile_path, 'w') do |f|
        f.write(<<-"END")
          flavor 'file://#{@test_repo_path}', '~> 1.1.1'
        END
      end
    end

    after :each do
      clean_up_stashed_stuffs()
    end

    it 'should install Vim plugins according to VimFlavor' do
      File.exists?(@facade.lockfile_path).should be_false
      File.exists?(@vimfiles_path).should be_false
      @facade.lockfile.should be_nil

      @facade.install(@vimfiles_path)

      File.exists?(@facade.lockfile_path).should be_true
      File.exists?(@vimfiles_path).should be_true
      @facade.lockfile.flavors.values.each do |f|
        File.exists?(f.make_deploy_path(@vimfiles_path)).should be_true
      end
    end

    it 'should respect existing VimFlavor.lock if possible' do
      def self.install()
        @facade.install(@vimfiles_path)
        [
          @facade.lockfile.flavors.map {|_, f| f.locked_version},
          @facade.flavorfile.flavors.count(),
        ]
      end

      result1 = self.install()
      update_a_test_repo(@test_repo_path)
      result2 = self.install()

      result2.should == result1
    end
  end

  describe '#upgrade' do
    before :each do
      @test_repo_path = "#{Vim::Flavor::DOT_PATH}/test/origin"
      @tmp_path = "#{Vim::Flavor::DOT_PATH}/tmp"
      @vimfiles_path = "#{Vim::Flavor::DOT_PATH}/vimfiles"
      @facade = described_class.new()
      @facade.flavorfile_path = "#{@tmp_path}/VimFlavor"
      @facade.lockfile_path = "#{@tmp_path}/VimFlavor.lock"

      create_a_test_repo(@test_repo_path)
      FileUtils.mkdir_p(@tmp_path)
      File.open(@facade.flavorfile_path, 'w') do |f|
        f.write(<<-"END")
          flavor 'file://#{@test_repo_path}', '~> 1.1.1'
        END
      end
    end

    after :each do
      clean_up_stashed_stuffs()
    end

    it 'should upgrade Vim plugins according to VimFlavor' do
      File.exists?(@facade.lockfile_path).should be_false
      File.exists?(@vimfiles_path).should be_false
      @facade.lockfile.should be_nil

      @facade.upgrade(@vimfiles_path)

      File.exists?(@facade.lockfile_path).should be_true
      File.exists?(@vimfiles_path).should be_true
      @facade.lockfile.flavors.values.each do |f|
        File.exists?(f.make_deploy_path(@vimfiles_path)).should be_true
      end
    end

    it 'should always upgrade existing VimFlavor.lock' do
      def self.upgrade()
        @facade.upgrade(@vimfiles_path)
        [
          @facade.lockfile.flavors.map {|_, f| f.locked_version},
          @facade.flavorfile.flavors.count(),
        ]
      end

      result1 = self.upgrade()
      update_a_test_repo(@test_repo_path)
      result2 = self.upgrade()

      result2.should_not == result1
    end
  end
end
