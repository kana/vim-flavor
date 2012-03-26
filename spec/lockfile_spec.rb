require 'bundler/setup'
require 'fileutils'
require 'spec_helper'
require 'vim-flavor'

describe Vim::Flavor::LockFile do
  with_temporary_directory

  before :each do
    @lockfile_path = "#{@tmp_path}/VimFlavor.lock"
  end

  it 'should be initialized with a given path and no flavor' do
    lf = described_class.new(@lockfile_path)

    lf.path.should == @lockfile_path
    lf.flavors.should be_empty
  end

  it 'should be able to persist its content' do
    @flavor1 = Vim::Flavor::Flavor.new()
    @flavor1.groups = [:default]
    @flavor1.locked_version = Gem::Version.create('1.2.3')
    @flavor1.repo_name = 'kana/vim-smartinput'
    @flavor1.repo_uri = 'git://github.com/kana/vim-smartinput.git'
    @flavor1.version_contraint = Vim::Flavor::VersionConstraint.new('>= 0')

    FileUtils.mkdir_p(File.dirname(@lockfile_path))
    lf = described_class.new("#{@lockfile_path}.1")

    lf.flavors.should be_empty

    File.exists?(lf.path).should be_false

    lf.save()

    File.exists?(lf.path).should be_true

    lf.flavors[@flavor1.repo_uri] = @flavor1
    lf.load()

    lf.flavors.should be_empty

    lf.flavors[@flavor1.repo_uri] = @flavor1
    lf.save()
    lf.load()

    lf.flavors.should == {@flavor1.repo_uri => @flavor1}
  end

  describe '::poro_from_flavors and ::flavors_from_poro' do
    before :each do
      @flavor1 = Vim::Flavor::Flavor.new()
      @flavor1.groups = [:default]
      @flavor1.locked_version = Gem::Version.create('1.2.3')
      @flavor1.repo_name = 'kana/vim-smartinput'
      @flavor1.repo_uri = 'git://github.com/kana/vim-smartinput.git'
      @flavor1.version_contraint = Vim::Flavor::VersionConstraint.new('>= 0')
      @flavor2 = Vim::Flavor::Flavor.new()
      @flavor2.groups = [:default]
      @flavor2.locked_version = Gem::Version.create('4.5.6')
      @flavor2.repo_name = 'kana/vim-smarttill'
      @flavor2.repo_uri = 'git://github.com/kana/vim-smarttill.git'
      @flavor2.version_contraint = Vim::Flavor::VersionConstraint.new('>= 0')
      @flavors = {
        @flavor1.repo_uri => @flavor1,
        @flavor2.repo_uri => @flavor2,
      }
      @flavors_in_poro = {
        @flavor1.repo_uri => {
          :groups => @flavor1.groups,
          :locked_version => @flavor1.locked_version.to_s(),
          :repo_name => @flavor1.repo_name,
          :version_contraint => @flavor1.version_contraint.to_s(),
        },
        @flavor2.repo_uri => {
          :groups => @flavor2.groups,
          :locked_version => @flavor2.locked_version.to_s(),
          :repo_name => @flavor2.repo_name,
          :version_contraint => @flavor2.version_contraint.to_s(),
        },
      }
    end

    it 'should create PORO from flavors' do
      described_class.poro_from_flavors(@flavors).should == @flavors_in_poro
    end

    it 'should create flavors from PORO' do
      described_class.flavors_from_poro(@flavors_in_poro).should == @flavors
    end
  end
end
