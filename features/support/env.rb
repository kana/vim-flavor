require 'aruba/api'
require 'aruba/cucumber'
require 'fileutils'
require 'vim-flavor'

class FakeUserEnvironment
  include Vim::Flavor::ShellUtility

  def add_new_versions_to_repo(basename, versions)
    repository_path = make_repo_path(basename)
    doc_name = basename.split('/').last.sub(/^vim-/, '')
    sh <<-"END"
      {
        cd '#{repository_path}' &&
        mkdir -p doc &&
        for v in #{versions}
        do
          echo "*#{doc_name}* $v" >'doc/#{doc_name}.txt'
          git add doc
          git commit -m "Version $v"
          git tag -m "Version $v" "$v"
        done
      } >/dev/null
    END
  end

  def expand(virtual_path)
    virtual_path.gsub(/\$([a-z_]+)/) {
      variable_table[$1]
    }
  end

  def make_cached_repo_path(repo_name, stash_path)
    "#{stash_path}/repos/#{repo_name.zap}"
  end

  def make_flavor_path(vimfiles_path, repo_name)
    "#{vimfiles_path.to_flavors_path}/#{repo_name.zap}"
  end

  def make_repo_path(basename)
    "#{expand("$tmp")}/repos/#{basename}"
  end

  def make_repo_uri(basename)
    "file://#{make_repo_path(basename)}"
  end

  def variable_table
    @variable_table ||= Hash.new
  end
end

Before do
  variable_table['version'] = Vim::Flavor::VERSION

  variable_table['tmp'] = File.absolute_path(current_dir)

  steps %Q{
    Given a directory named "home"
  }
  variable_table['home'] = File.absolute_path(File.join([current_dir, 'home']))

  @aruba_timeout_seconds = 5
end

Aruba.configure do |config|
  config.before_cmd do |cmd|
    set_env 'HOME', variable_table['home']
    set_env 'VIM_FLAVOR_GITHUB_URI_PREFIX', expand('file://$tmp/repos/')
    set_env 'VIM_FLAVOR_GITHUB_URI_SUFFIX', ''
  end
end

World do
  FakeUserEnvironment.new
end
