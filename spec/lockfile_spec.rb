require 'bundler/setup'
require 'fileutils'
require 'vim-flavor'

describe Vim::Flavor::LockFile do
  before :each do
    @lockfile_path = "#{Vim::Flavor::DOT_PATH}/VimFlavor.lock"
  end

  after :each do
    FileUtils.rm_rf([Vim::Flavor::DOT_PATH], :secure => true)
  end

  it 'should be initialized with a given path and no flavor' do
    lf = described_class.new(@lockfile_path)

    lf.path.should == @lockfile_path
    lf.flavors.should be_empty
  end

  it 'should be able to persist its content' do
    FileUtils.mkdir_p(File.dirname(@lockfile_path))
    lf = described_class.new("#{@lockfile_path}.1")

    lf.flavors.should be_empty

    File.exists?(lf.path).should be_false

    lf.save()

    File.exists?(lf.path).should be_true

    lf.flavors['foo'] = 'bar'
    lf.load()

    lf.flavors.should be_empty

    lf.flavors['foo'] = 'bar'
    lf.save()
    lf.load()

    lf.flavors.should == {'foo' => 'bar'}
  end

  describe '::poro_from_flavors' do
    it 'should create PORO from flavors'
  end

  describe '::flavors_from_poro' do
    it 'should create flavors from PORO'
  end
end
