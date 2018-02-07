require 'aruba/api'
require 'aruba/cucumber'
require 'fileutils'
require 'pathname'
require 'vim-flavor'

class FakeUserEnvironment
  include Vim::Flavor::ShellUtility

  def add_new_versions_to_repo(basename, versions, flavorfile_content = nil)
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
          #{
            %Q{
              cat <<'FF' >#{repository_path.to_flavorfile_path}
#{expand(flavorfile_content)}
FF
              git add #{repository_path.to_flavorfile_path}
            } if flavorfile_content
          }
          git commit -m "Version $v"
          git tag -m "Version $v" "$v"
        done
      } >/dev/null
    END
    versions.split.each do |v|
      variable_table["#{basename}_rev_#{v.gsub('.', '')}"] = sh(<<-"END").chomp
        cd '#{repository_path}' &&
        git rev-list -n1 '#{v}' --
      END
    end
  end

  def expand(virtual_path)
    virtual_path.gsub(/\$([A-Za-z0-9_]+)/) {
      variable_table[$1]
    }
  end

  def path_for_step(path)
    cwd = Pathname.new(expand_path('.'))
    pathd = Pathname.new(path)
    if not pathd.absolute?
      pathd = cwd + pathd
    end

    pathd.relative_path_from(cwd).to_s
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

  variable_table['tmp'] = File.absolute_path(expand_path('.'))

  steps %Q{
    Given a directory named "home"
  }
  variable_table['home'] = File.absolute_path(File.join([expand_path('.'), 'home']))

  @aruba_timeout_seconds = 5

  set_environment_variable 'VIM_FLAVOR_HOME', variable_table['home']
  set_environment_variable 'VIM_FLAVOR_GITHUB_URI_PREFIX', expand('file://$tmp/repos/')
  set_environment_variable 'VIM_FLAVOR_GITHUB_URI_SUFFIX', ''
end

World do
  FakeUserEnvironment.new
end
