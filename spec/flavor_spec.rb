require 'bundler/setup'
require 'fileutils'
require 'vim-flavor'

describe Vim::Flavor::Flavor do
  describe '#clone' do
    it 'should clone the repository into a given path'
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
