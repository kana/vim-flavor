require 'bundler/setup'
require 'vim-flavor'

describe Vim::Flavor::VersionConstraint do
  before :all do
    @base_version_s = '1.2'
    @backward_compatible_versions = [
      '1.2.4',
      '1.2.10',
      '1.3.5',
      '1.10.100',
    ]
    @backward_incompatible_versions = [
      '2.0',
      '3000',
    ]
    @old_versions = [
      '1.1.1',
      '1.1',
      '0.2.4',
    ]
  end

  it 'should accept ">=" operator' do
    vc = described_class.new('>= 0.0.0')
    vc.base_version.should == Gem::Version.create('0.0.0')
    vc.operator.should == '>='
  end

  it 'should accept "~>" operator' do
    vc = described_class.new('~> 1.2.3')
    vc.base_version.should == Gem::Version.create('1.2.3')
    vc.operator.should == '~>'
  end

  it 'should not accept unknown operators' do
    expect {
      described_class.new('?? 6.6.6')
    }.to raise_error(RuntimeError)
  end

  it 'should not accept invalid format' do
    expect {
      described_class.new('6.6.6')
    }.to raise_error(RuntimeError)
  end

  describe '#==' do
    it 'should compare instances by their properties' do
      vc_gc1 = described_class.new('~> 1')
      vc_ge1 = described_class.new('>= 1')
      vc_ge1d = described_class.new('>= 1')
      vc_ge2 = described_class.new('>= 2')

      vc_ge1.should == vc_ge1d
      vc_ge1.should_not == vc_gc1
      vc_ge1.should_not == vc_ge2
    end
  end

  describe '>=' do
    it 'should be compatible with backward-compatible versions' do
      vc = described_class.new('>= ' + @base_version_s)
      @backward_compatible_versions.each do |v|
        vc.compatible?(v).should be_true
      end
    end

    it 'should be compatible with backward-incompatible versions' do
      vc = described_class.new('>= ' + @base_version_s)
      @backward_incompatible_versions.each do |v|
        vc.compatible?(v).should be_true
      end
    end

    it 'should not be compatible with any older versions' do
      vc = described_class.new('>= ' + @base_version_s)
      @old_versions.each do |v|
        vc.compatible?(v).should be_false
      end
    end
  end

  describe '~>' do
    it 'should be compatible with backward-compatible versions' do
      vc = described_class.new('~> ' + @base_version_s)
      @backward_compatible_versions.each do |v|
        vc.compatible?(v).should be_true
      end
    end

    it 'should not be compatible with backward-incompatible versions' do
      vc = described_class.new('~> ' + @base_version_s)
      @backward_incompatible_versions.each do |v|
        vc.compatible?(v).should be_false
      end
    end

    it 'should not be compatible with any older versions' do
      vc = described_class.new('~> ' + @base_version_s)
      @old_versions.each do |v|
        vc.compatible?(v).should be_false
      end
    end
  end

  describe 'find_the_best_version' do
    it 'should find the best version from given versions' do
      described_class.new('~> 1.2.3').find_the_best_version([
        '1.2.3',
        '1.2.6',
        '1.2.9',
        '1.3.0',
        '2.0.0',
      ].map {|vs| Gem::Version.create(vs)}).should ==
        Gem::Version.create('1.2.9')

      described_class.new('>= 0').find_the_best_version([
        '1.2.3',
        '1.2.6',
        '1.2.9',
        '1.3.0',
        '2.0.0',
      ].map {|vs| Gem::Version.create(vs)}).should ==
        Gem::Version.create('2.0.0')
    end
  end
end
