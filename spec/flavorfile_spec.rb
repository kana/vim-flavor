require 'bundler/setup'
require 'vim-flavor'

describe Vim::Flavor::FlavorFile do
  describe 'flavor' do
    before :each do
      @ff = described_class.new()
    end

    it 'should treat "$USER/$REPO" as a GitHub repository' do
      @ff.interpret do
        flavor 'kana/vim-textobj-indent'
      end

      f = @ff.flavors.values[0]
      f.repo_name.should == 'kana/vim-textobj-indent'
      f.repo_uri.should == 'git://github.com/kana/vim-textobj-indent.git'
    end

    it 'should treat "$REPO" as a repository under vim-scripts.org' do
      @ff.interpret do
        flavor 'fakeclip'
      end

      f = @ff.flavors.values[0]
      f.repo_name.should == 'fakeclip'
      f.repo_uri.should == 'git://github.com/vim-scripts/fakeclip.git'
    end

    it 'should treat "git://..." as an arbitrary Git repository' do
      @ff.interpret do
        flavor 'git://github.com/kana/vim-smartinput.git'
      end

      f = @ff.flavors.values[0]
      f.repo_name.should == 'git://github.com/kana/vim-smartinput.git'
      f.repo_uri.should == 'git://github.com/kana/vim-smartinput.git'
    end

    it 'should treat "https://..." as an arbitrary Git repository' do
      @ff.interpret do
        flavor 'https://kana@github.com/kana/vim-smartinput.git'
      end

      f = @ff.flavors.values[0]
      f.repo_name.should == 'https://kana@github.com/kana/vim-smartinput.git'
      f.repo_uri.should == 'https://kana@github.com/kana/vim-smartinput.git'
    end

    it 'should use no version constraint by default' do
      @ff.interpret do
        flavor 'kana/vim-textobj-indent'
      end

      f = @ff.flavors.values[0]
      f.version_contraint.base_version.version.should == '0'
      f.version_contraint.operator.should == '>='
    end

    it 'should use a given version contraint' do
      @ff.interpret do
        flavor 'kana/vim-textobj-indent', '~> 0.1.0'
      end

      f = @ff.flavors.values[0]
      f.version_contraint.base_version.version.should == '0.1.0'
      f.version_contraint.operator.should == '~>'
    end

    it 'should categorize the given plugin into the :default group' do
      @ff.interpret do
        flavor 'kana/vim-textobj-indent'
      end

      f = @ff.flavors.values[0]
      f.groups.should == [:default]
    end

    it 'should categorize the given plugin into the specified groups' do
      @ff.interpret do
        flavor 'kana/vim-textobj-entire'
        flavor 'kana/vim-textobj-indent', :groups => [:development]
        flavor 'kana/vim-textobj-syntax', :groups => [:test]
      end

      fe = @ff.flavors['git://github.com/kana/vim-textobj-entire.git']
      fe.groups.should == [:default]
      fi = @ff.flavors['git://github.com/kana/vim-textobj-indent.git']
      fi.groups.should == [:default, :development]
      fs = @ff.flavors['git://github.com/kana/vim-textobj-syntax.git']
      fs.groups.should == [:default, :test]
    end
  end

  describe 'group' do
    before :each do
      @ff = described_class.new()
    end

    it 'should categorize inner flavors into the specified groups' do
      @ff.interpret do
        flavor 'kana/vim-textobj-entire'

        group :development do
          flavor 'kana/vim-textobj-indent'
        end

        group :test do
          flavor 'kana/vim-textobj-syntax', :groups => [:development]
        end
      end

      fe = @ff.flavors['git://github.com/kana/vim-textobj-entire.git']
      fe.groups.should == [:default]
      fi = @ff.flavors['git://github.com/kana/vim-textobj-indent.git']
      fi.groups.should == [:default, :development]
      fs = @ff.flavors['git://github.com/kana/vim-textobj-syntax.git']
      fs.groups.should == [:default, :test, :development]
    end
  end
end
